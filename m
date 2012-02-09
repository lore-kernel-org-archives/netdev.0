From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 37/50] usbnet: set addr_assign_type if random_ether_addr() used
Date: Thu, 9 Feb 2012 15:55:14 +0100
Message-ID: <201202091555.15071.oliver@neukum.org>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <201202082230.19936.oliver@neukum.org> <874nv07au1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Danny Kukawka <danny.kukawka@bisect.de>,
	Danny Kukawka <dkukawka@suse.de>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874nv07au1.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 9. Februar 2012, 07:57:42 schrieb Bj=C3=B8rn Mork:
> > Don't you set the flag too early here? By that time we don't know
> > whether the device provides a real MAC, do we?
>=20
> Maybe it makes sense to set it here anyway since usbnet provides this
> default random address, and let the minidrivers which set a real mac
> also clear the flag?  But in that case the patch need to clear the fl=
ag
> everywhere a minidriver currently updates the address.
>=20

Doable, but where is the benefit? It seems better to me to make an effo=
rt
to guess as well as possible in the common code.

	Regards
		Oliver
