From: P@draigBrady.com
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 07 Dec 2004 13:39:14 +0000
Message-ID: <41B5B282.9040909@draigBrady.com>
References: <20041206205305.GA11970@soohrt.org>	 <20041206134849.498bfc93.davem@davemloft.net>	 <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com>	 <20041207112139.GA3610@soohrt.org> <16821.42080.932184.167780@robur.slu.se>	 <20041207125001.GA26644@soohrt.org> <1102424673.1093.124.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Desler <kdesler@soohrt.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261612AbULGNjg@vger.kernel.org>
To: hadi@cyberus.ca
In-Reply-To: <1102424673.1093.124.camel@jzny.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2004-12-07 at 07:50, Karsten Desler wrote:
>=20
>=20
>>Currently I'm having problems capturing packets with tcpdump (lots of
>>"packets dropped by kernel") which indicates to me that there's
>>genuinely not much (enough) idle time sitting around.
>>
>=20
> Ah, more hints. So you are not trying to forward - rather just packet
> capturing?
> Are you using a tcpdump patched with mmaped packet socket?
>=20
> The 230-240Kpps you are reporting as a capture dont seem as unreasona=
ble
> as i thought then. Neither would the CPU use.

Yes this is vital Karsten, otherwise tcpdump
will do 2 syscalls per packet, which is the
bottleneck in my experience.

You may want to try a simpler capture program that
uses the kernel PACKET_MMAP feature directly:
http://www.scaramanga.co.uk/code-fu/lincap.c

--=20
P=E1draig Brady - http://www.pixelbeat.org
--
