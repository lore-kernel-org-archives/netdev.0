From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Subject: Re: Kernel Panic with bonding + IPoIB on 3.2.9
Date: Tue, 20 Mar 2012 14:33:03 +1100
Message-ID: <CAOzFzEgSWHqabw9yq6JxhD+CxQY61O+gqGwPMdbWPC=M+_oZAw@mail.gmail.com>
References: <CAOzFzEiufg40gKBH6D7zeB47SebfPvgzqOLxhF5eQqpYd-r4zQ@mail.gmail.com>
	<CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ@mail.gmail.com>
	<CAL1RGDVAd-LiS0sy6RAFNzkUuXrcuGv829nADcnxUnC2tfx3bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Roland Dreier <roland@purestorage.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL1RGDVAd-LiS0sy6RAFNzkUuXrcuGv829nADcnxUnC2tfx3bw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20 March 2012 06:05, Roland Dreier <roland@purestorage.com> wrote:
> On Sun, Mar 18, 2012 at 1:21 PM, Joseph Glanville
> <joseph.glanville@orionvm.com.au> wrote:
>> [ =A0422.047024] kernel BUG at net/core/dev.c:1896!
>
> So this line is
>
> =A0 =A0 =A0 =A0BUG_ON(offset >=3D skb_headlen(skb));
>
> right? =A0No paritcular idea how we hit this, though...

Yep... I have looked through most of /drivers/net/bonding and I can't
really see why it should be blowing up there.. it really should cause
the BUG_ON under normal IPoIB if the MTU was the cause - yet I have
not experienced this.
The bonding code doesn't seem to do anything special with the MTU
other than propagating changes to the slaves.

--=20
=46ounder | Director | VP Research
Orion Virtualisation Solutions=A0|=A0www.orionvm.com.au=A0| Phone: 1300=
 56
99 52 | Mobile: 0428 754 846
