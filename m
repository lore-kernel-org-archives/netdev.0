From: =?ISO-8859-1?Q?Espen_Fjellv=E6r_Olsen?= <espenfjo@gmail.com>
Subject: Re: 2.6.13-rc4-mm1: iptables DROP crashes the computer
Date: Sun, 7 Aug 2005 19:43:06 +0200
Message-ID: <7aaed09105080710433d45e0ae@mail.gmail.com>
References: <7aaed091050807100843454603@mail.gmail.com>
	<7aaed09105080710121bba1b5b@mail.gmail.com>
	<20050807172333.GF3513@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux <linux-kernel@vger.kernel.org>, discuss@x86-64.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050807172333.GF3513@stusta.de>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On 07/08/05, Adrian Bunk <bunk@stusta.de> wrote:
> On Sun, Aug 07, 2005 at 07:12:00PM +0200, Espen Fjellv=E6r Olsen wrote:
>=20
> > After execing "iptables -A INPUT -j DROP" my computer crashes hard. It
> > dosent hang immediately, but after a couple of seconds.
> > The machine is an amd64, running a clean x86_64 environment.
> > uname -a: Linux gentoo 2.6.13-rc4-mm1 #1 PREEMPT Thu Aug 4 01:01:44
> > CEST 2005 x86_64 AMD Athlon(tm) 64 Processor 3400+ AuthenticAMD
> >...
>=20
> Is this reproducible or did it happen only once?

It is reproducible, happens each time when running "iptables -A INPUT
-j DROP", other rules like "iptables -A INPUT -m --state
ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT" works well tho.

> Are there any messages that might give a hint where to search for the
> problem?

The kernel log dont give any messages before the crash, and since the
computer crash hard i cant check for relevant messages after the crash
;)
=20
> You are reporting this against 2.6.13-rc4-mm1, but are attaching a
> .config of 2.6.13-rc5-mm1. Which kernels are affected, and which are
> not?

Im sorry about that glitch, recently compiled 2.6.13-rc5-mm1, but i
got a kernel panic at boot, havent looked into that yet, but it might
be related to ACPI.

The config for rc4-mm1 and rc5-mm1 is similar.

> Does it still happen if you compile your kernel with preemption
> disabled?

Havent tried this yet, but ill do it right away.

> Please send the output of ./scripts/ver_linux .

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux gentoo 2.6.13-rc4-mm1 #1 PREEMPT Thu Aug 4 01:01:44 CEST 2005
x86_64 AMD Athlon(tm) 64 Processor 3400+ AuthenticAMD GNU/Linux

Gnu C                  3.4.4
Gnu make               3.80
binutils               2.16.1
util-linux             2.12q
mount                  2.12q
module-init-tools      3.2-pre7
e2fsprogs              1.38
reiserfsprogs          line
reiser4progs           line
xfsprogs               2.6.25
Linux C Library        2.3.5
Dynamic linker (ldd)   2.3.5
Procps                 3.2.5
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
udev                   065
Modules Loaded         iptable_filter ip_tables snd_seq_midi
snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event
snd_seq_midi_emul snd_seq snd_pcm_oss snd_mixer_oss rtc ntfs
snd_emu10k1 snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm
snd_timer snd_page_alloc snd_util_mem snd_hwdep snd soundcore
usb_storage uhci_hcd usbcore


--=20
Mvh / Best regards
Espen Fjellv=E6r Olsen
espenfjo@gmail.com
Norway
