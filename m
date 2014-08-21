From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH 8/8] staging: et131x: Implement NAPI support
Date: Thu, 21 Aug 2014 10:25:09 +0100
Message-ID: <20140821092508.GC2230@msilap.einon.net>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
 <1408573078-9320-9-git-send-email-mark.einon@gmail.com>
 <20140820202545.3a8bafd0@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140820202545.3a8bafd0@uryu.home.lan>
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

On Wed, Aug 20, 2014 at 08:25:45PM -0700, Stephen Hemminger wrote:
> On Wed, 20 Aug 2014 23:17:58 +0100
> Mark Einon <mark.einon@gmail.com> wrote:
> 
> > -	bool done = true;
> > +	int count = 0;
> > +	int limit = budget;
> > +	bool not_done = false;
> 
> Don't use negative variables. Better to keep the original done variable.

Fair comment, I'll send a v2.

Cheers,

Mark
