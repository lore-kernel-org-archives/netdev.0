From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc2-mm1: e1000e global symbols must be
	renamed
Date: Thu, 09 Aug 2007 10:06:26 -0700
Message-ID: <46BB4992.2020504@intel.com>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
	<20070809135131.GN6997@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070809135131.GN6997@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Thu, Aug 09, 2007 at 01:51:06AM -0700, Andrew Morton wrote:
>> ...
>> - There is a new e1000 driver in git-netdev-all, called e1000e.  I'm sure
>>   the developers would like it tested.  Please cc netdev@vger.kernel.org on
>>   any reports.
>> ...
>> Changes since 2.6.23-rc2-mm1:
>> ...
>>  git-netdev-all.patch
>> ...
>>  git trees
>> ...
> 
> <--  snip  -->
> 
> ...
>   LD      drivers/net/built-in.o
> drivers/net/e1000e/built-in.o: In function `e1000_read_mac_addr':
> (.text+0x3470): multiple definition of `e1000_read_mac_addr'
> drivers/net/e1000/built-in.o:(.text+0xb6cc): first defined here
> drivers/net/e1000e/built-in.o: In function `e1000_set_ethtool_ops':
> (.text+0x594d): multiple definition of `e1000_set_ethtool_ops'
> drivers/net/e1000/built-in.o:(.text+0xc97a): first defined here
> ...
> make[3]: *** [drivers/net/built-in.o] Error 1

ack, I'll step on that and make it go away :)

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
