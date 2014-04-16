From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 16 Apr 2014 14:25:30 -0400
Message-ID: <20140416182530.GB550@redhat.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com>
 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net>
 <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org>
 <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com>
 <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>, David Miller <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>, Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 11:13:31AM -0700, Andy Lutomirski wrote:

[..]
> > Ok, so passing cgroup information is not necessarily a problem as long
> > as it is not used for authentication. So say somebody is just logging
> > all the client request and which cgroup client was in, that should not
> > be a problem.
> 
> Do you consider correct attribution of logging messages to be
> important?  If so, then this is a kind of authentication, albeit one
> where the impact of screwing it up is a bit lower.

So not passing cgroup information makes attribution more correct. Just
logging of information is authentication how? Both kernel and user space
log message into /var/log/messages and kernel messages are prefixed with
"kernel". So this somehow becomes are sort of authentication. I don't
get it.

> 
> >
> > I agree that before somebody uses cgroup information for authentication
> > purposes, may be there needs to be a bigger debate whether this info
> > can be used safely for authentication purposes or not and in what
> > circumstances it is safe to use for authentication.
> 
> I thought that the original intended user of these patches was SSSD.
> I have no idea what SSSD wanted them for, but I think it may better.

SSSD wanted to use this information too. And I think this is a good time 
to revisit and discuss can cgroup information be used safely for
authentication or not.

> 
> >
> > But that does not mean that API to pass the cgroup information around is
> > wrong.
> >
> 
> It may not be wrong, but it might be extremely difficult or impossible
> to use it safely.  I think that's something to avoid.

Atleast I can't see a problem with logging example yet.

Thanks
Vivek
