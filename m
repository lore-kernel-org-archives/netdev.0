From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] net: ethernet: intel: ixgbe:
 ixgbe_main.c: Cleaning up missing null-terminate in conjunction with
 strncpy
Date: Tue, 29 Jul 2014 20:20:44 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73369BE0@ORSMSX104.amr.corp.intel.com>
References: <1406384676-2606-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<20140728083935.6f4b77c1@samsung-9>
	<CAFo99gacYur41ZPng3v4KUq_6C5vY6hTrXz1fsCJnCGHY5_i0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "rickard_strandqvist@spectrumdigital.se"
	<rickard_strandqvist@spectrumdigital.se>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAFo99gacYur41ZPng3v4KUq_6C5vY6hTrXz1fsCJnCGHY5_i0A@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2014-07-29 at 14:15 +0200, Rickard Strandqvist wrote:
> Den 29 jul 2014 04:40 skrev "Stephen Hemminger" <stephen@networkplumber.org
> >:
> >
> > On Sat, 26 Jul 2014 16:24:36 +0200
> > Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:
> >
> > > Replacing strncpy with strlcpy to avoid strings that lacks null
> terminate.
> > >
> > > Signed-off-by: Rickard Strandqvist <
> rickard_strandqvist@spectrumdigital.se>
> > > ---
> >                            hw->mac.type, hw->phy.type, hw->phy.sfp_type,
> >
> > This patch doesn't change anything.
> > Netdev is already zeroed when allocated therefore doing strncpy()
> guarantees
> > it will be null terminated.
> 
> Hi Stephen
> 
> It's not clear that alloc_etherdev_mq() will zero the memory area:
> 
<snip>

Thanks Rickard, given strncpy to strlcpy gets suggested by static code
generators this will probably come up again even if it results in no
real change.  I (covering for Jeff Kirsher) went ahead and added it to
our internal tree.


------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
