From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: net and drivers/net: Warn on missing blank
 line after variable declaration
Date: Fri, 07 Mar 2014 01:30:37 -0800
Message-ID: <1394184637.16156.58.camel@joe-AO722>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <20140306.142919.763823800315842610.davem@davemloft.net>
 <1394148520.16156.8.camel@joe-AO722> <20140307075247.GA29018@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140307075247.GA29018@mwanda>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 10:54 +0300, Dan Carpenter wrote:
> How many warnings does this generate does this generate when you run it
> across the whole tree?

A lot.

Check back with me after the week or so
it'll take to run on this little netboook.

Try this with both patches applied if you want
to know yourself...

$ git ls-files | grep "\.[ch]$"| \
  xargs ./scripts/checkpatch.pl -f --strict --types=spacing --emacs --terse | \
  grep "Missing a blank"
