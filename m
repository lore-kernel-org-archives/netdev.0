From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 14:09:40 +0100
Message-ID: <43BE6C14.5080904@cosmosbay.com>
References: <20060105235845.967478000@sorel.sous-sol.org> <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org> <43BE43B6.3010105@cosmosbay.com> <200601061358.42344.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932384AbWAFNKQ@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200601061358.42344.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =C3=A9crit :
> On Friday 06 January 2006 11:17, Eric Dumazet wrote:
>=20
>> I assume that if a CPU queued 10.000 items in its RCU queue, then th=
e
>> oldest entry cannot still be in use by another CPU. This might sound=
s as a
>> violation of RCU rules, (I'm not an RCU expert) but seems quite reas=
onable.
>=20
> I don't think it's a good assumption. Another CPU might be stuck in a=
 long=20
> running interrupt, and still have a reference in the code running bel=
ow
> the interrupt handler.
>=20
> And in general letting correctness depend on magic numbers like this =
is=20
> very nasty.
>=20

I agree Andi, I posted a 2nd version of the patch with no more assumpti=
ons.

Eric
