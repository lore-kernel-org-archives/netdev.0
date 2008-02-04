From: "Oliver Pinter" <oliver.pntr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Wireless,
	ath5k] 2.6.24-git13 9135f1901ee6449dfe338adf6e40e9c2025b8150
Date: Mon, 4 Feb 2008 22:40:01 +0100
Message-ID: <6101e8c40802041340g749b1e03k70fda7fdb21452d7@mail.gmail.com>
References: <6101e8c40802040600q804e40cs97d0031920e58d9d@mail.gmail.com>
	<47A774AB.5060008@gmail.com>
	<6101e8c40802041334o20b2b391la5b0a5f557ee67c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <6101e8c40802041334o20b2b391la5b0a5f557ee67c5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
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

On 2/4/08, Oliver Pinter <oliver.pntr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 2/4/08, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On 02/04/2008 03:00 PM, Oliver Pinter (Pint=E9r Oliv=E9r) wrote:
> > > git top: 9135f1901ee6449dfe338adf6e40e9c2025b8150
> > >
> > > [  399.582185] wpa_supplicant[4383]: segfault at 30 ip 080697ca sp
> > > bf87a690 error 4 in wpa_supplicant[8048000+4c000]
> > > [  406.277199] wpa_supplicant[4384]: segfault at 30 ip 080697ca sp
> > > bfc13a30 error 4 in wpa_supplicant[8048000+4c000]
> > > [  407.586375] wpa_supplicant[4385]: segfault at 30 ip 080697ca sp
> > > bf9ed000 error 4 in wpa_supplicant[8048000+4c000]
> > > [  411.671037] wpa_supplicant[4386]: segfault at 30 ip 080697ca sp
> > > bf8f3710 error 4 in wpa_supplicant[8048000+4c000]
> > > [  412.569843] wpa_supplicant[4387]: segfault at 30 ip 080697ca sp
> > > bfc19a30 error 4 in wpa_supplicant[8048000+4c000]
> > > [  413.118874] wpa_supplicant[4388]: segfault at 30 ip 080697ca sp
> > > bfc9cab0 error 4 in wpa_supplicant[8048000+4c000]
> >
> > Seems like wpa_supplicant is broken. Is this a regression?
>
> yes, but with madwifi is all ok
> >
> > > home:~# wpa_supplicant -Dwext -iath0 -c
> > /etc/wpa_supplicant/wpa_supplicant.conf
> >
> > ath0? udev renamed it?
>
> yes
> >
> > > ioctl[SIOCSIWAUTH]: Operation not supported
> > > WEXT auth param 4 value 0x0 - bind(PF_UNIX): Address already in use
> >
> > 4 - 0x0 is TKIP, nothing we should worry about.
> >
> > > ctrl_iface exists and seems to be in use - cannot override it
> > > Delete '/var/run/wpa_supplicant/ath0' manually if it is not used
> anymore
> > > Failed to initialize control interface '/var/run/wpa_supplicant'.
> > > You may have another wpa_supplicant process already running or the fi=
le
> > was
> > > left by an unclean termination of wpa_supplicant in which case you wi=
ll
> > need
> > > to manually remove this file before starting wpa_supplicant again.
> >
> > Have you?
>
> yes
> >
> > I guess ltrace would help here. And maybe strace...
> >
>
> strace attached and wpa_supplicant more verbose output
> --
> Thanks,
> Oliver
>
02:01.0 Ethernet controller: Atheros Communications, Inc. AR5212
802.11abg NIC (rev 01)
        Subsystem: D-Link System Inc D-Link AirPlus DWL-G520 Wireless
PCI Adapter(rev.B)
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 168 (2500ns min, 7000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at e4000000 (32-bit, non-prefetchable) [size=3D64K]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D2 PME-

02:01.0 Ethernet controller: Atheros Communications, Inc. AR5212
802.11abg NIC (rev 01)
00: 8c 16 13 00 06 00 90 02 01 00 00 02 08 a8 00 00
10: 00 00 00 e4 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 01 50 00 00 86 11 13 3a
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 01 0a 1c
40: 00 00 00 00 01 00 c2 01 00 40 00 c6 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


-- =

Thanks,
Oliver
