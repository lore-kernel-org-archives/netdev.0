From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Fri, 24 Sep 2010 10:16:58 -0400
Message-ID: <1285337818.13976.697.camel@bigi>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	 <m1hbhgq1v1.fsf@fess.ebiederm.org> <1285240926.5036.7.camel@bigi>
	 <20100923145856.GB1160234@jupiter.n2.diac24.net>
	 <1285329084.13976.661.camel@bigi>
	 <20100924125704.GA1551619@jupiter.n2.diac24.net>
	 <1285335173.13976.693.camel@bigi>
	 <20100924140943.GB1551619@jupiter.n2.diac24.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100924140943.GB1551619@jupiter.n2.diac24.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-24 at 16:09 +0200, David Lamparter wrote:

> I understood your point. What I'm saying is that that functional graph
> you're describing is too simplistic do be a workable model. Your graph
> allows for what you're trying to do, yes. But your graph is not modeling
> the reality.

How about we put this specific point to rest by agreeing to
disagree? ;->

> Err... I'm migrating netdevs to assign them to namespaces to allow them
> to use them? Setup, basically. Either way a device move only happens as
> result of some administrative action; be it creating a new namespace or
> changing the physical/logical network setup.
> 

Ok, different need. You have a much more basic requirement than i do.

> wtf is a "remote" namespace?
> 

A namespace that is remotely located on another machine/hardware ;->

> Can you please describe your application that requires moving possibly
> several network devices together with "their" routes to a different
> namespace?

scaling and availability are the driving requirements.

cheers,
jamal
