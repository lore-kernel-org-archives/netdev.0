From: P@draigBrady.com
Subject: Re: Fw: [Bugme-new] [Bug 2782] New: ksoftirqd load system, kernel
 hang after a few minuts
Date: Fri, 28 May 2004 11:35:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B715F3.9010200@draigBrady.com>
References: <20040527115311.472d3c3a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, dav@neocom.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040527115311.472d3c3a.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Suggest you try an up-to-date kernel.
>=20
> Begin forwarded message:
>=20
> Date: Thu, 27 May 2004 09:19:49 -0700
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 2782] New: ksoftirqd load system, kernel hang=
 after a few minuts
>=20
>=20
> http://bugme.osdl.org/show_bug.cgi?id=3D2782
>=20
>            Summary: ksoftirqd load system, kernel hang after a few minu=
ts
>     Kernel Version: 2.4.20-2.4.22
>             Status: NEW
>           Severity: blocking
>              Owner: other_other@kernel-bugs.osdl.org
>          Submitter: dav@neocom.fr

I've just seen something similar with official 2.4.20+e1000 v5.2.30.1
on a Dual Intel Xeon CPU 2.6G+hyperthreading. Note I use IRQ affinity
so both ksoftirqd_CPU[02] are at 100%.

The following is repeatable in about a minute which is good.
I send in around 700,000 packets per second on each of 2 interfaces,
and let the packets continually overflow the (4096 entry) buffers.
After about a minute I can't receive any traffic, and a couple
of occasions the machine just rebooted, so something is getting
corrupted. I was suspecting the e1000 driver buffer management until
I seen this?

P=E1draig.
