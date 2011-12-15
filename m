From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: Re: kenel level packet capturing
Date: Thu, 15 Dec 2011 13:19:33 -0200
Message-ID: <CADsjWXS5e6xdgHfJCtnj09Ky90QT4c4=W5BjpJg_4D1uJE-Ykw@mail.gmail.com>
References: <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
	<20111213.133629.1213042365300662857.davem@davemloft.net>
	<CAKj1SsNO_uJuVtKs_-tygcd=QDesKkYa=9DVeajhK73LFV-opA@mail.gmail.com>
	<20111214.110919.1286184647888114902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: raviraj.j1991@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111214.110919.1286184647888114902.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Raviraj,

You could be interested in taking a look at
"Documentation/networking/packet_mmap.txt" (this talks about mmap()'d
packet ring implementation for AF_PACKET).

Rgds,
Eduardo Panisset.

On Wed, Dec 14, 2011 at 2:09 PM, David Miller <davem@davemloft.net> wro=
te:
> From: raviraj joshi <raviraj.j1991@gmail.com>
> Date: Wed, 14 Dec 2011 16:16:01 +0530
>
>> On Wed, Dec 14, 2011 at 12:06 AM, David Miller <davem@davemloft.net>=
 wrote:
>>> From: raviraj joshi <raviraj.j1991@gmail.com>
>>> Date: Tue, 13 Dec 2011 17:34:22 +0530
>>>
>>>> We have decided to use PF_RING(a kernel module to capture packets)=
 for
>>>> the same due to the number of advantages.
>>>
>>> What "advantages"? =A0The AF_PACKET socket layer already upstream i=
n the
>>> kernel supports every relevant performance feature PF_RING does, an=
d
>>> then some.
>> I refered to the document on "A Measurement Study of Packet Receptio=
n
>> using Linux"[1] =A0which said pf_ring maintains
>> a ring buffer, so we dont have to issue a receive system call for ea=
ch
>> packet in contrast to AF_PACKET which issues a system call for each
>> packet(pls correct me if i am wrong).
>
> AF_PACKET supports mmap()'d packet rings, and even supports variable
> packet lengths within those rings.
>
> AF_PACKET supports all the worthwhile performance features of PR_RING
> and it's upstream, stop kidding yourself.
>
> I'm really sick and tired of people saying PF_RING is better than
> what we have upstream, it really isn't.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
