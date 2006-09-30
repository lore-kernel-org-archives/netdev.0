From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/6]: powerpc/cell spidernet ethtool -i version number info.
Date: Sat, 30 Sep 2006 12:33:45 +0200
Message-ID: <200609301233.45871.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com> <20060929232139.GL6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:38884 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750766AbWI3Kdp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 06:33:45 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060929232139.GL6433@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Saturday 30 September 2006 01:21 schrieb Linas Vepstas:
> This patch adds version information as reported by
> ethtool -i to the Spidernet driver.
>
> From: James K Lewis <jklewis@us.ibm.com>
> Signed-off-by: James K Lewis <jklewis@us.ibm.com>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Same comment as last time this was submitted:

> @@ -2303,6 +2304,8 @@ static struct pci_driver spider_net_driv
> =A0 */
> =A0static int __init spider_net_init(void)
> =A0{
> +=A0=A0=A0=A0=A0=A0=A0printk("spidernet Version %s.\n",VERSION);
> +
> =A0=A0=A0=A0=A0=A0=A0=A0if (rx_descriptors < SPIDER_NET_RX_DESCRIPTOR=
S_MIN) {
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rx_descriptors =3D SP=
IDER_NET_RX_DESCRIPTORS_MIN;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_info("adjusting rx=
 descriptors to %i.\n",

This is missing a printk level and a space character. More importantly,
you should not print the presence of the driver to the syslog, but
the presence of a device driven by it.

	Arnd <><
