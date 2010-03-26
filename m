From: Brandon Black <blblack@gmail.com>
Subject: Re: [PATCH] Add MSG_WAITFORONE flag to recvmmsg
Date: Fri, 26 Mar 2010 17:55:18 -0500
Message-ID: <84621a61003261555q2c78f6a8o5b438113bed6bd2@mail.gmail.com>
References: <20100326223530.GA11817@xpc.home>
	 <1269643470.2256.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269643470.2256.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 26, 2010 at 5:44 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Hmmm, no need to test !datagram, just do :
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0++datagrams;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags & MSG_WAITFORONE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flags |=3D MSG=
_DONTWAIT;
>

Ok.  I've never been through this process before.  Do I resubmit a new
subject/thread with the changed patch and [PATCH v2] at this point?
Any other nits about how the patch was sent before I do?

Thanks,
-- Brandon
