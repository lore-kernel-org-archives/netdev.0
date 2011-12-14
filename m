From: David Miller <davem@davemloft.net>
Subject: Re: kenel level packet capturing
Date: Wed, 14 Dec 2011 11:09:19 -0500 (EST)
Message-ID: <20111214.110919.1286184647888114902.davem@davemloft.net>
References: <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
	<20111213.133629.1213042365300662857.davem@davemloft.net>
	<CAKj1SsNO_uJuVtKs_-tygcd=QDesKkYa=9DVeajhK73LFV-opA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: raviraj.j1991@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAKj1SsNO_uJuVtKs_-tygcd=QDesKkYa=9DVeajhK73LFV-opA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: raviraj joshi <raviraj.j1991@gmail.com>
Date: Wed, 14 Dec 2011 16:16:01 +0530

> On Wed, Dec 14, 2011 at 12:06 AM, David Miller <davem@davemloft.net> =
wrote:
>> From: raviraj joshi <raviraj.j1991@gmail.com>
>> Date: Tue, 13 Dec 2011 17:34:22 +0530
>>
>>> We have decided to use PF_RING(a kernel module to capture packets) =
for
>>> the same due to the number of advantages.
>>
>> What "advantages"? =A0The AF_PACKET socket layer already upstream in=
 the
>> kernel supports every relevant performance feature PF_RING does, and
>> then some.
> I refered to the document on "A Measurement Study of Packet Reception
> using Linux"[1]  which said pf_ring maintains
> a ring buffer, so we dont have to issue a receive system call for eac=
h
> packet in contrast to AF_PACKET which issues a system call for each
> packet(pls correct me if i am wrong).

AF_PACKET supports mmap()'d packet rings, and even supports variable
packet lengths within those rings.

AF_PACKET supports all the worthwhile performance features of PR_RING
and it's upstream, stop kidding yourself.

I'm really sick and tired of people saying PF_RING is better than
what we have upstream, it really isn't.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
