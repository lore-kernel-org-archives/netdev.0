From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 3 Nov 2009 16:56:50 -0500
Message-ID: <20091103215650.GT8227@kvack.org>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com> <20091103200155.GQ8227@kvack.org> <m1my338fbi.fsf@fess.ebiederm.org> <m1y6mn708g.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754660AbZKCV4r@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1y6mn708g.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 03, 2009 at 01:43:43PM -0800, Eric W. Biederman wrote:
> I guess in particular what I would expect is that if we can do 35000
> interfaces in 63s with an O(N^2) algorithm.  Then we should be able to
> do 35000 interfaces with an O(NlogN) algorithm in under a second.
> Which for your application should make the time essentially flat in
> the number of interfaces.

That's the wrong way to interprete the numbers.  The 35000 number of 63s is 
the time that it takes 63s to add 5000 more interfaces in the 30,000 to 
35,000 range.  This includes the time required to add a point to point ip 
route on the interface and bring the interface up.

		-ben
