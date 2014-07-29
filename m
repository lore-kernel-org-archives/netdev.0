From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: ethernet: intel: ixgbe:
 ixgbe_main.c: Cleaning up missing null-terminate in conjunction with
 strncpy
Date: Tue, 29 Jul 2014 14:15:21 +0200
Message-ID: <CAFo99gacYur41ZPng3v4KUq_6C5vY6hTrXz1fsCJnCGHY5_i0A@mail.gmail.com>
References: <1406384676-2606-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<20140728083935.6f4b77c1@samsung-9>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5451312130202625977=="
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140728083935.6f4b77c1@samsung-9>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============5451312130202625977==
Content-Type: multipart/alternative; boundary=089e011609b85aa8da04ff53fe67

--089e011609b85aa8da04ff53fe67
Content-Type: text/plain; charset=UTF-8

Den 29 jul 2014 04:40 skrev "Stephen Hemminger" <stephen@networkplumber.org
>:
>
> On Sat, 26 Jul 2014 16:24:36 +0200
> Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:
>
> > Replacing strncpy with strlcpy to avoid strings that lacks null
terminate.
> >
> > Signed-off-by: Rickard Strandqvist <
rickard_strandqvist@spectrumdigital.se>
> > ---
>                            hw->mac.type, hw->phy.type, hw->phy.sfp_type,
>
> This patch doesn't change anything.
> Netdev is already zeroed when allocated therefore doing strncpy()
guarantees
> it will be null terminated.

Hi Stephen

It's not clear that alloc_etherdev_mq() will zero the memory area:

http://www.filewatcher.com/p/kernel-doc-2.6.32-71.14.1.el6.centos.plus.noarch.rpm.8821380/usr/share/man/man9/alloc_etherdev_mq.9.gz.html

If we are convinced that this is done, it works whith strncpy and sizeof()
- 1

But on the next with "part_str" I can not see that it can not be created
without a trailing zero. Except of course "Unknown" is less than 11
characters, but if we think that way, you can go back to using strcpy.

BR
Rickard Strandqvist

--089e011609b85aa8da04ff53fe67--


--===============5451312130202625977==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
--===============5451312130202625977==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5451312130202625977==--
