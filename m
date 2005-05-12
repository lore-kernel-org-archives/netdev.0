From: Manuel Perez Ayala <mperaya@alcazaba.unex.es>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Thu, 12 May 2005 20:06:12 +0200
Message-ID: <20050512200612.v4srgy5xk4o4oos4@158.49.151.11>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
	<1115743966.8570.26.camel@rh4>
	<20050511080446.fnstrvtzq8gk8884@158.49.151.11>
	<1115825081.8570.93.camel@rh4>
	<20050512112827.7danjtr4kckg8swc@158.49.151.11> <4283853C.9070608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4283853C.9070608@hp.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:

> Since both read and write boundaries are being changed, doesn't=20
> netperf need to be run in each direction?

I have two twin systems: PowerMac G4 both with 3com 3c996T connected to a=
 3com
gigabit switch, same memomry, same disk, same os. I have compiled and=20
installed
the driver with the harcoded best dma configuration on both.

These are the netperf results from one side:

afs02-i:/usr/share/doc/netperf# netperf -H afs01-i
TCP STREAM TEST to afs01-i
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

87380  16384  16384    10.00     671.71


And these are the netperf results from the other side:

afs01-i:~# netperf -H afs02-i
TCP STREAM TEST to afs02-i
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

87380  16384  16384    10.00     667.96

And on the local device:

afs01-i:~# netperf -H afs01-i
TCP STREAM TEST to afs01-i
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

87380  16384  16384    10.00    1834.33


----------
Manuel Perez Ayala
mperaya@alcazaba.unex.es
Facultad de Biblioteconom=EDa y Documentaci=F3n
Universidad de Extremadura
