From: Sebastian <sebastian@expires0606.datenknoten.de>
Subject: Re: [PATCH] pcmcia: avoid binding hostap_cs to Orinoco cards
Date: Mon, 27 Mar 2006 13:44:44 +0200
Message-ID: <1143459885.9691.6.camel@coruscant.datenknoten.de>
References: <200603012259.k21MxEN3013604@hera.kernel.org>
	 <44063023.9010603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux@dominikbrodowski.net, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750933AbWC0Lo0@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44063023.9010603@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> commit 40e3cad61197fce63853e778db020f7637d988f2
> tree 6e086c930e1aef0bb24eb61af42d1f3c1fb7d38c
> parent f0892b89e3c19c7d805825ca12511d26dcdf6415
> author Pavel Roskin <proski@gnu.org> Tue, 28 Feb 2006 11:18:31 -0500
> committer Dominik Brodowski <linux@dominikbrodowski.net> Wed, 01 Mar 
> 2006 11:12:00 +0100
> 
> [PATCH] pcmcia: avoid binding hostap_cs to Orinoco cards
> 
> Don't just use cards with PCMCIA ID 0x0156, 0x0002.  Make sure that
> the vendor string is "Intersil" or "INTERSIL"
> 
> Signed-off-by: Pavel Roskin <proski@gnu.org>
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
>  drivers/net/wireless/hostap/hostap_cs.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletion(-)


Hello,

this patch seems to break my setup. The hostap_cs driver included in
kernel 2.6.16 does not detect my Prism 2 WLAN card anymore, although it
is *not* Orinoco. With 2.6.15.5 it still worked.

FYI:
pccardctl info
PRODID_1=""
PRODID_2="Link DWL-650 11Mbps WLAN Card"
PRODID_3="Version 01.02"
PRODID_4=""
MANFID=0156,0002
FUNCID=6

Sebastian
