From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: =?windows-1252?Q?Re=3A_Kernel=2DDOS_error_in_arp_mechanism_=96_no_delete_?=
	=?windows-1252?Q?off_incomplete_arp_adresses?=
Date: Sat, 17 Dec 2011 14:26:01 +0100
Message-ID: <CAFLxGvxjLCyMCPXtpm7a7RaOL4A4=bhCLPKD=FVAc8xOdx_CsQ@mail.gmail.com>
References: <4EEC5286.3070408@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Robert Gladewitz <gladewitz@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EEC5286.3070408@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2011 at 9:27 AM, Robert Gladewitz <gladewitz@gmx.de> wr=
ote:
> Hello,
>
> first i have to say sorry for m y bad english. I try my best to descr=
ipe the
> error.
>
> I Use Linux-Routers for internal and external firewall components. Fo=
r this
> I Use own kernel configurations und use only the drivers an modules w=
hat I
> need. Other features and modules I deactivated in my kernel versions
>
> Since the kernel version 2.6.36 there is some mistake in the ipv4 arp
> implementation. The the System try to find an unknown system, the sen=
d an
> =93who is=94 and marked the ip address as =93incomplete=94 (German: u=
nvollst=E4ndig).
> The thing is, usually linux delete all incomplete and complete entrie=
s in
> some time, but in all kernel versions since 2.6.36 he doas not delete=
 any
> addresses.
>
> In my case, I scan my network-segmens for new devices (Kaspersky, Lan=
desk)
> and on this process, the router learned a lot of incomplete addresses=
=2E I
> have some class b networks (from the history), and this means the rou=
ter
> will be learned mor then 2^16 adresses.
>
> Now the kerlen learn a maximum addresses =96 I know this is defined o=
n
> gc_thresh1 , gc_thresh2 and gc_thresh3 in the proc system under
> sys.net.ipv4.neight.default. If the table have the maximum addresses =
in the
> table (default=3D1024), no new host can send traffic packet over this=
 router.
> This means, we have a classical risk of DOS. In my case, I have only =
an
> internal risk, but some providers may have also external risc.
>
> I hope, my description help you to find this error. I send also my ke=
rnel
> config, may there is some relation to small configurations in kernel
>
> Viele Gr=FC=DFe
>
> Robert Gladewitz
>

CC'ing netdev.

--=20
Thanks,
//richard
