From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 13:03:54 -0800
Message-ID: <CAKgT0UdtW5RkYK+zgLsj6t64eWFCf==Hza3m_4N1Drwh-YOtAQ@mail.gmail.com>
References: <568F87AC.60405@oracle.com>
	<1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	<CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
	<1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
	<1454522077.7627.264.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UeueE5EhLu0-8jcr0+su81sOV_qCpb-KGRf7q4EKsw1QQ@mail.gmail.com>
	<1454527426.7627.282.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?UTF-8?B?SMOla29uIEJ1Z2dl?= <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454527426.7627.282.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 11:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-02-03 at 10:24 -0800, Alexander Duyck wrote:
>
>> If this is only meant to be a performance modification and is only
>> really targeted at TCP TSO/GRO then all I ask is that we use a name
>> like tcp_max_gso_frags and relocate the sysctl to the TCP section.
>> Otherwise if we are actually going to try to scope this out on a wider
>> level and limit all frags which is what the name implies then the
>> patch set needs to make a better attempt at covering all cases where
>> it may apply.
>
>
> This is the goal.
>
> Other skb providers (like tun and af_packet) will also use this optional
> limit.
>
> I fail to see why Hans should send a complete patch series.

You realize that conflicts with what anybody else would be told.  What
was provided in this patch is a half solution, and it may cause bigger
messes since it is unclear exactly how this sysctl is meant to be
used.

> We will send followup patches, as we always did.
>
> I will send the GRO change for example.
>
> So please keep a sysctl name _without_ TCP in it, it really has nothing
> to do with TCP.

In the end I am not the one you have to convince.  I have simply
stated my opinion, and I guess we will have to agree to disagree.  It
is entirely up to Dave if he wants to apply it or not.  I have slides
I need to work on for next week.. :-)

- Alex
