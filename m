From: Grant Grundler <iod00d@hp.com>
Subject: Re: [openib-general] [PATCH 5/5] [RFC] Infiniband: connection	abstraction
Date: Wed, 18 Jan 2006 10:49:45 -0800
Message-ID: <20060118184945.GG6818@esmail.cup.hp.com>
References: <ORSMSX401yEXUIEAOeI00000043@orsmsx401.amr.corp.intel.com> <adar775wnfi.fsf@cisco.com> <43CE8695.9080401@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030279AbWARStl@vger.kernel.org>
To: Sean Hefty <mshefty@ichips.intel.com>
Content-Disposition: inline
In-Reply-To: <43CE8695.9080401@ichips.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2006 at 10:19:01AM -0800, Sean Hefty wrote:
> Roland Dreier wrote:
> > > +	UCMA_MAX_BACKLOG	= 128
> >
> >Is there any reason that we might want to make this a tunable?  Maybe
> >as a module parameter that's writable in sysfs...
> 
> There's no reason not to make this tunable.

Yes, there are reasons to NOT make something a tunable:
o increases system complexity (admin)
o increases the amount of documentation (learning curve)
o increases test matrix/cost (devel/support cost)
o generally hurts performance (var vs a constant of the same value)

Any reason to make something a tunable has to compensate
for the above drawbacks. An answer to Roland's question
is a reasonable prerequisite if someone wants add a tunable.

IB doesn't have the much in /sys/class/infiniband* or module parameters
and I think that's a Good Thing.

grant
