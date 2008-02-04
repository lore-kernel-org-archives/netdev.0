From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Wireless,
	ath5k] 2.6.24-git13 9135f1901ee6449dfe338adf6e40e9c2025b8150
Date: Mon, 04 Feb 2008 21:25:15 +0100
Message-ID: <47A774AB.5060008@gmail.com>
References: <6101e8c40802040600q804e40cs97d0031920e58d9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: =?ISO-8859-2?Q?=22Oliver_Pinter_=28Pint=E9r_Oliv=E9r=29=22?=
	<oliver.pntr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <6101e8c40802040600q804e40cs97d0031920e58d9d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/04/2008 03:00 PM, Oliver Pinter (Pint=E9r Oliv=E9r) wrote:
> git top: 9135f1901ee6449dfe338adf6e40e9c2025b8150
> =

> [  399.582185] wpa_supplicant[4383]: segfault at 30 ip 080697ca sp
> bf87a690 error 4 in wpa_supplicant[8048000+4c000]
> [  406.277199] wpa_supplicant[4384]: segfault at 30 ip 080697ca sp
> bfc13a30 error 4 in wpa_supplicant[8048000+4c000]
> [  407.586375] wpa_supplicant[4385]: segfault at 30 ip 080697ca sp
> bf9ed000 error 4 in wpa_supplicant[8048000+4c000]
> [  411.671037] wpa_supplicant[4386]: segfault at 30 ip 080697ca sp
> bf8f3710 error 4 in wpa_supplicant[8048000+4c000]
> [  412.569843] wpa_supplicant[4387]: segfault at 30 ip 080697ca sp
> bfc19a30 error 4 in wpa_supplicant[8048000+4c000]
> [  413.118874] wpa_supplicant[4388]: segfault at 30 ip 080697ca sp
> bfc9cab0 error 4 in wpa_supplicant[8048000+4c000]

Seems like wpa_supplicant is broken. Is this a regression?

> home:~# wpa_supplicant -Dwext -iath0 -c /etc/wpa_supplicant/wpa_supplican=
t.conf

ath0? udev renamed it?

> ioctl[SIOCSIWAUTH]: Operation not supported
> WEXT auth param 4 value 0x0 - bind(PF_UNIX): Address already in use

4 - 0x0 is TKIP, nothing we should worry about.

> ctrl_iface exists and seems to be in use - cannot override it
> Delete '/var/run/wpa_supplicant/ath0' manually if it is not used anymore
> Failed to initialize control interface '/var/run/wpa_supplicant'.
> You may have another wpa_supplicant process already running or the file w=
as
> left by an unclean termination of wpa_supplicant in which case you will n=
eed
> to manually remove this file before starting wpa_supplicant again.

Have you?

I guess ltrace would help here. And maybe strace...
