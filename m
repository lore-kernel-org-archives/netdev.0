From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Wed, 7 Nov 2007 14:13:29 -0500
Message-ID: <20071107191329.GC30169@tuxdriver.com>
References: <20071106200700.GF4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071106200700.GF4440-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff,

If you haven't already pulled this then please hold-off.  I'll post
a new request soon.

Thanks,

John

On Tue, Nov 06, 2007 at 03:07:00PM -0500, John W. Linville wrote:
> Jeff,
> 
> Here are a few fixes for 2.6.24.  The iwlwifi "is_power_of_2" patch is
> a little questionable as a fix.  But it does bring the buildtime check
> in iwl_tx_queue_init in-line with the runtime check in iwl_queue_init,
> and it is 2x a one-liner -- so I think it is worthwhile.
> 
> Thanks,
> 
> John
> 
> ---
> 
> Individual patches available here:
> 
> 	http://www.kernel.org/pub//linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/
> 
> ---
> 
> The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
>   Alan Cox (1):
>         ata_piix: Add additional PCI identifier for 40 wire short cable
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> Holger Schurig (1):
>       libertas: fixes for slow hardware
> 
> Ivo van Doorn (1):
>       rt2x00: Block adhoc & master mode
> 
> John W. Linville (1):
>       hermes: clarify Intel reference in Kconfig help
> 
> Marcelo Tosatti (1):
>       libertas: properly account for queue commands
> 
> Michael Buesch (1):
>       b43: pcmcia-host initialization bugfixes
> 
> Pierre Ossman (1):
>       libertas: make if_sdio align packets
> 
> Randy Dunlap (1):
>       hostap: fix section mismatch warning
> 
> Robert P. J. Day (1):
>       iwlwifi: Use more obvious "is_power_of_2" macro.
> 
> Roel Kluin (1):
>       ipw2100: fix postfix decrement errors
> 
>  drivers/net/wireless/Kconfig                |    2 +-
>  drivers/net/wireless/b43/pcmcia.c           |   44 +++++++++++++++-----------
>  drivers/net/wireless/hostap/hostap_pci.c    |    6 ++--
>  drivers/net/wireless/ipw2100.c              |    4 +-
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 +-
>  drivers/net/wireless/iwlwifi/iwl4965-base.c |    3 +-
>  drivers/net/wireless/libertas/cmd.c         |   10 ++++--
>  drivers/net/wireless/libertas/if_cs.c       |    7 +++-
>  drivers/net/wireless/libertas/if_sdio.c     |    4 ++-
>  drivers/net/wireless/rt2x00/rt2x00mac.c     |    8 +++++
>  10 files changed, 58 insertions(+), 33 deletions(-)
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
