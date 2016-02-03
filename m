From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 03 Feb 2016 09:54:37 -0800
Message-ID: <1454522077.7627.264.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568F87AC.60405@oracle.com>
	 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	 <CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
	 <1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
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
In-Reply-To: <CAKgT0UdGeOJ+NyegQ6vPCdXF39NoiFXQdTjAOoFaokteNWiygw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-03 at 09:43 -0800, Alexander Duyck wrote:

> Read the history.  I still say it is best if we don't accept a partial
> solution.  If we are going to introduce the sysctl as a core item it
> should function as a core item and not as something that belongs to
> TCP only.


But this patch is the base, adding both the core sysctl and its first
usage.

Do we really need to split it in 2 patches ? Really ?

The goal is to use it in all skb providers were it might be a
performance gain, once they are identified.

Your points were already raised and will be addressed, by either me or
you. And maybe others.
