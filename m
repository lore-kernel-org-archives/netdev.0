From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 03 Feb 2016 11:23:46 -0800
Message-ID: <1454527426.7627.282.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568F87AC.60405@oracle.com>
	 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	 <CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
	 <1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
	 <1454522077.7627.264.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UeueE5EhLu0-8jcr0+su81sOV_qCpb-KGRf7q4EKsw1QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?ISO-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UeueE5EhLu0-8jcr0+su81sOV_qCpb-KGRf7q4EKsw1QQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-03 at 10:24 -0800, Alexander Duyck wrote:

> If this is only meant to be a performance modification and is only
> really targeted at TCP TSO/GRO then all I ask is that we use a name
> like tcp_max_gso_frags and relocate the sysctl to the TCP section.
> Otherwise if we are actually going to try to scope this out on a wider
> level and limit all frags which is what the name implies then the
> patch set needs to make a better attempt at covering all cases where
> it may apply.


This is the goal.

Other skb providers (like tun and af_packet) will also use this optional
limit.

I fail to see why Hans should send a complete patch series.

We will send followup patches, as we always did.

I will send the GRO change for example.

So please keep a sysctl name _without_ TCP in it, it really has nothing
to do with TCP.
