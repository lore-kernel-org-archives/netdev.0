From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Wed, 31 Mar 2010 12:21:10 -0500
Message-ID: <20100331172110.GA18838@us.ibm.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> The main short coming of using multiple network namespaces today
> is that only network devices for the primary network namespaces
> can be put in the kobject layer and sysfs.
> 
> This is essentially the earlier version of this patchset that was
> reviewed before, just now on top of a version of sysfs that doesn't
> need cleanup patches to support it.
> 
> I have been running these patches in some form for well over a
> year so the basics should at least be solid.  
> 
> This patchset is currently against 2.6.34-rc1.
> 
> This patchset is just the basic infrastructure a couple of more pretty
> trivial patches are needed to actually enable network namespaces to use this.
> My current plan is to send those after these patches have made it through
> review.

Thanks very much for keeping this going, Eric!  I'm going to keep
looking through the code some more, but so far I see no problems.

Acked-by: Serge Hallyn <serue@us.ibm.com>

to the full patchset.  I'm really hoping you'll also include the
patch to implement the netns support (i.e. basically commit
fdc0adeaa8bfab9a179e1eb349cab400ddb70403 that you sent inline this
morning to Tejun).

thanks,
-serge
