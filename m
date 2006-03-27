From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] pcmcia: avoid binding hostap_cs to Orinoco cards
Date: Mon, 27 Mar 2006 12:12:52 -0500
Message-ID: <1143479572.21729.9.camel@dv>
References: <200603012259.k21MxEN3013604@hera.kernel.org>
	 <44063023.9010603@pobox.com>
	 <1143459885.9691.6.camel@coruscant.datenknoten.de>
	 <20060327164844.GF14403@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sebastian <sebastian@expires0606.datenknoten.de>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux@dominikbrodowski.net, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750720AbWC0RNW@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060327164844.GF14403@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-27 at 11:48 -0500, John W. Linville wrote:
> > this patch seems to break my setup. The hostap_cs driver included in
> > kernel 2.6.16 does not detect my Prism 2 WLAN card anymore, although it
> > is *not* Orinoco. With 2.6.15.5 it still worked.

It mean hostap_cs was identifying the card solely by its numeric ID
(0x0156, 0x0002) instead of the vendor strings.  Since that particular
numeric ID was used both by cards that are supported by hostap_cs and
those that are not, it cannot be used in hostap_cs.

Sebastian, please send me the output of "pccardctl ident" and I'll
submit the patch for hostap_cs.

> This patch didn't come through me, so I don't know much about it.
> Hopefully Pavel or Dominik can comment?

-- 
Regards,
Pavel Roskin
