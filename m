From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: Off-by-one bug at unix_mkname ?
Date: Mon, 28 Mar 2005 11:25:39 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0503281124450.18443@yvahk01.tjqt.qr>
References: <200503281700.HHE91205.FtVLOStGOSPMYJFMN@I-love.sakura.ne.jp>
 <20050328.172108.30349253.yoshfuji@linux-ipv6.org>
 <20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1283855629-238969141-1112001939=:18443"
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        from-linux-kernel@I-love.sakura.ne.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1283855629-238969141-1112001939=:18443
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j2S9T7Mu028569


On Mar 28 2005 17:39, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=
=8E wrote:

>+		 *	This may look like an off by one error but it is
>+		 *	a bit more subtle. 108 is the longest valid AF_UNIX
>+		 *	path for a binding. sun_path[108] doesnt as such
>+		 *	exist. However in kernel space we are guaranteed that
>+		 *	it is a valid memory location in our kernel
>+		 *	address buffer.
>+		 */

Now, does 2.6. _still_ guarantee that 108 is a valid offset?



Jan Engelhardt
--=20
No TOFU for me, please.
--1283855629-238969141-1112001939=:18443--
