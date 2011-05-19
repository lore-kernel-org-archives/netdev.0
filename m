From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Wed, 18 May 2011 20:56:33 -0700
Message-ID: <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
References: <20110518.155200.801089483916944725.davem@davemloft.net>
 <1305771744-83951-1-git-send-email-tsunanet@gmail.com> <20110518.223622.1525088601595365235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, hagen@jauu.net,
	eric.dumazet@gmail.com, alexander.zimmermann@comsys.rwth-aachen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518.223622.1525088601595365235.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 7:36 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Benoit Sigoure <tsunanet@gmail.com>
> Date: Wed, 18 May 2011 19:22:24 -0700
>
>> Prior to this patch, Linux would always use 3 seconds (compile-time
>> constant) as the initial RTO. =A0Draft RFC 2988bis-02 proposes to tu=
ne
>> this down to 1 second and, in case of a timeout during the TCP 3WHS,
>> revert the RTO back up to 3 seconds when data transmission begins.
>
> We just had a discussion where it was determined that changes to
> these settings are "network specific" and therefore that if it
> is appropriate at all (I'm still not convinced) it is only suitable
> as a routing metric.

=46air enough.  I'll take another stab at it and see if I can change
this to be on a per network basis.  Do I need any patch that's not yet
in Linus' tree?  I'm referring to this:

On Tue, May 17, 2011 at 5:20 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Adding many knobs to each clone had a huge cost on previous kernels.
> (Think some machines have millions entries in IP route cache), this u=
sed
> quite a lot of memory.
>
> With latest David work, we'll consume less ram, because we can now sh=
are
> settings, instead of copying them on each dst entry.

If this has already been merged then it sounds like I should have
everything I need..?

--=20
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
