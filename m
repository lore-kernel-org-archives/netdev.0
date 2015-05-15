From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
 instances
Date: Thu, 14 May 2015 22:03:57 -0400
Message-ID: <20150515020357.GC10526@madcap2.tricolour.ca>
References: <cover.1429252659.git.rgb@redhat.com>
 <2487286.y6vyJ9A3er@x2>
 <20150512195759.GA9832@madcap2.tricolour.ca>
 <2918460.dpKocsKt4o@x2>
 <87iobvnp1t.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87iobvnp1t.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15/05/14, Eric W. Biederman wrote:
> Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > On Tuesday, May 12, 2015 03:57:59 PM Richard Guy Briggs wrote:
> >> On 15/05/05, Steve Grubb wrote:
> >> > I think there needs to be some more discussion around this. It seems like
> >> > this is not exactly recording things that are useful for audit.
> >> 
> >> It seems to me that either audit has to assemble that information, or
> >> the kernel has to do so.  The kernel doesn't know about containers
> >> (yet?).
> >
> > Auditing is something that has a lot of requirements imposed on it by security 
> > standards. There was no requirement to have an auid until audit came along and 
> > said that uid is not good enough to know who is issuing commands because of su 
> > or sudo. There was no requirement for sessionid until we had to track each 
> > action back to a login so we could see if the login came from the expected 
> > place. 
> 
> Stop right there.
> 
> You want a global identifier in a realm where only relative identifiers
> exist, and make sense.

I am assuming he wants an identifier unique per container on one kernel
and what happens on other kernels is a matter for a management
application to take care of.  This kernel doesn't have to deal with it
other than taking information from a container management application.

> I am sorry that isn't going to happen. EVER.
> 
> Square peg, round hole.  It doesn't work, it doesn't make sense, and
> most especially it doesn't allow anyone to reconstruct anything, because
> it does not make sense and does not match what the kernel is doing.
> 
> Container IDs do not, and will not exist.  There is probably something
> reasonable in your request but until you stop talking that nonsense I
> can't see it.

I didn't see anything in any of what Steve said that suggested it was to
be unique beyond that one kernel.

> Global IDs take us into the namespace of namespaces problem and that
> isn't going to happen.  I have already bent as far in this direction as
> I can go.  Further namespace creation is not a privileged event which
> makes the requestion for a container ID make even less sense.  With
> anyone able to create whatever they want it will not be a identifier
> that makes any sense to someone reading an audit log.

Again, I assume this is up to a container management application that
will manage its pool of container hosts and an audit aggregator.

You keep raising an objection about the unworkability of a "namespace of
namespaces".  Just so we are all on the same page here, can you explain
exactly what you mean with "namespace of namespaces"?

> Eric

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
