From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 00/17] netfilter: add namespace support for
 netfilter protos
Date: Wed, 2 May 2012 02:40:20 +0200
Message-ID: <20120502004020.GA14999@1984>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
 <m1zk9rwxf2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zk9rwxf2.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Tue, May 01, 2012 at 11:47:45AM -0700, Eric W. Biederman wrote:
> Gao feng <gaofeng@cn.fujitsu.com> writes:
> 
> > Currently the sysctl of netfilter proto is not isolated, so when
> > changing proto's sysctl in container will cause the host's sysctl
> > be changed too. it's not expected.
> >
> > This patch set adds the namespace support for netfilter protos.
> >
> > impletement four pernet_operations to register sysctl and initial
> > pernet data for proto.
> >
> > -ipv4_net_ops is used to register tcp4(compat),
> >  udp4(compat),icmp(compat),ipv4(compat).
> > -ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
> > -sctp_net_ops is used to register sctp4(compat) and sctp6.
> > -udplite_net_ops is used to register udplite4 and udplite6
> >
> > extern l[3,4]proto (sysctl) register functions to make them support
> > namespace.
> >
> > finailly add namespace support for cttimeout.
> 
> I am a bit out of it this week so I could not look at these patches
> in the detail that I would like.  However skimming through it looks
> like you addressed your review comments, and the changes look like
> the kind of changes I would expect from something like this.
> 
> I assume you have tested to make certain your code actually works.
> 
> So on that basis for the patchset:
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Anyone else want to chime in or does everyone else figure
> that this code is ready to be merged and no additional comments
> are necessary?

I also want to see this code in this round of net-next.

Yet, I'd like to have it a closer look to the patches. Please, be
patient.
