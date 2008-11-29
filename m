From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes	allocation/deallocation
 on SMP
Date: Sat, 29 Nov 2008 09:07:07 +0100
Message-ID: <4930F82B.7030906@cosmosbay.com>
References: <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <20081128180318.GL10487@elte.hu> <1227898076.7392.16.camel@twins> <20081129063816.GA869@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081129063816.GA869-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig a =E9crit :
> On Fri, Nov 28, 2008 at 07:47:56PM +0100, Peter Zijlstra wrote:
>>> Wow, that's incredibly impressive! :-)
>> Yeah, we got a similar speedup on -rt by pushing those super-block f=
iles
>> list into per-cpu lists and doing crazy locking on them.
>>
>> Of course avoiding them all together, like done here is a nicer opti=
on
>> but is sadly not a possibility for regular files (until hch gets aro=
und
>> to removing the need for the list).
>=20
> We should have finished this long ago, thanks for the reminder.
>=20
>=20

inode_in_use could be percpu, at least.

Or just zap it, since we never have to scan it.
