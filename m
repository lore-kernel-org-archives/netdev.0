From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH -stable 3.18, backport] ipmr: fix possible race resulting
 from improper usage of IP_INC_STATS_BH() in preemptible context.
Date: Mon, 2 Nov 2015 22:48:59 -0500
Message-ID: <56382EAB.8020602@oracle.com>
References: <alpine.OSX.2.00.1511021633400.6869@animac.local>
 <1446511811.23275.37.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8MKSV2QtTvFoEXXFjRFsFFaae_FUbPiZn2SZC9fwAEPeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: stable <stable@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Ani Sinha <ani@arista.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAOxq_8MKSV2QtTvFoEXXFjRFsFFaae_FUbPiZn2SZC9fwAEPeQ@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2015 10:32 PM, Ani Sinha wrote:
> On Mon, Nov 2, 2015 at 4:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2015-11-02 at 16:40 -0800, Ani Sinha wrote:
>>> >> [ Upstream commit 44f49dd8b5a606870a1f2 ]
>> >
>> > Please carefully read Documentation/networking/netdev-FAQ.txt
> I don't see any recent releases of 3.18 version series in Greg KH's
> tree. Is the 3.18 stable train being maintained by Sasha here?
> 
> http://git.kernel.org/cgit/linux/kernel/git/sashal/linux-stable.git/
> 
> If that is the case, should 3.18 specific backport patches be sent
> directly to him ?

The documentation is a bit lacking here. I follow the same procedure
as Greg: Dave sends us backports for patches he picks for -stable and
I apply them.

The only difference is that my (currently empty) queue is located elsewhere:
https://git.kernel.org/cgit/linux/kernel/git/sashal/linux-stable.git/log/?h=linux-3.18.y-queue

To sum it up, no need to send anything regarding -stable  net/ to anyone,
Dave does all the heavy lifting there (thanks Dave!).


Thanks,
Sasha
