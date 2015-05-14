From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Thu, 14 May 2015 10:42:38 -0500
Message-ID: <87iobvnp1t.fsf@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com> <2487286.y6vyJ9A3er@x2>
	<20150512195759.GA9832@madcap2.tricolour.ca> <2918460.dpKocsKt4o@x2>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2918460.dpKocsKt4o@x2> (Steve Grubb's message of "Thu, 14 May
	2015 10:57:14 -0400")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tuesday, May 12, 2015 03:57:59 PM Richard Guy Briggs wrote:
>> On 15/05/05, Steve Grubb wrote:
>> > I think there needs to be some more discussion around this. It seems like
>> > this is not exactly recording things that are useful for audit.
>> 
>> It seems to me that either audit has to assemble that information, or
>> the kernel has to do so.  The kernel doesn't know about containers
>> (yet?).
>
> Auditing is something that has a lot of requirements imposed on it by security 
> standards. There was no requirement to have an auid until audit came along and 
> said that uid is not good enough to know who is issuing commands because of su 
> or sudo. There was no requirement for sessionid until we had to track each 
> action back to a login so we could see if the login came from the expected 
> place. 

Stop right there.

You want a global identifier in a realm where only relative identifiers
exist, and make sense.

I am sorry that isn't going to happen. EVER.

Square peg, round hole.  It doesn't work, it doesn't make sense, and
most especially it doesn't allow anyone to reconstruct anything, because
it does not make sense and does not match what the kernel is doing.

Container IDs do not, and will not exist.  There is probably something
reasonable in your request but until you stop talking that nonsense I
can't see it.

Global IDs take us into the namespace of namespaces problem and that
isn't going to happen.  I have already bent as far in this direction as
I can go.  Further namespace creation is not a privileged event which
makes the requestion for a container ID make even less sense.  With
anyone able to create whatever they want it will not be a identifier
that makes any sense to someone reading an audit log.

Eric
