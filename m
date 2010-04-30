From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: patch sysfs-implement-sysfs-tagged-directory-support.patch
 added to gregkh-2.6 tree
Date: Fri, 30 Apr 2010 09:29:40 -0500
Message-ID: <20100430142940.GC7187@us.ibm.com>
References: <12725729473590@kroah.org>
 <4BDA5A2D.6080904@kernel.org>
 <20100430044522.GA29845@suse.de>
 <m1aaslbjh4.fsf@fess.ebiederm.org>
 <4BDA6C90.9010303@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>, bcrl@lhnet.ca,
	benjamin.thery@bull.net, cornelia.huck@de.ibm.com,
	eric.dumazet@gmail.com, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52642 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933024Ab0D3RdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:33:15 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3UEOXnq021269
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:24:33 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3UETjhL150832
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:29:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3UETfkQ031424
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:29:45 -0400
Content-Disposition: inline
In-Reply-To: <4BDA6C90.9010303@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Tejun Heo (tj@kernel.org):
> Hello,
> 
> On 04/30/2010 07:24 AM, Eric W. Biederman wrote:
> >>> I wish at least more comments are added before it goes mainline.  I
> >>> don't really understand the current form.
> >>
> >> Ok, that's fine with me, I'll pull it back out.
> > 
> > ?????
> > 
> > Tejun you have offered nothing constructive to the review, except looking
> > and saying you don't understand what is going on.
> 
> Eric, no need to get too touchy and you're right in part in saying all
> I'm saying is basically "I don't understand it" which is the same
> reason why I'm not nacking it and explicitly stated that I would be
> okay with the series going in if Greg/Kay would be okay with it.
> Again, about the same thing with the above comment, I was *wishing*
> for more comments *before it goes mainline*.

I'm not sure if you mean "more in-line comments" or more discussion.  If
you mean the latter, then I think the patch intro was deceptive as it has
gotten more acks than that - I acked the whole set, and I think it didn't
get more discussion than it did because it got much discussion in previous
versions.

This subset looks a bit mysterious because it offers the support for
tagged /sys/class/net, but that implementation, which clarifies why some
of this is done, comes in the later patches in Eric's set.  Can you please
jump to his tree, take a look at 
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/ebiederm/linux-2.6.32-rc5-sysfs-enhancements.git;a=commit;h=e7468796a9756b28e0ab38eb021025bbd3712823
and let us know if that does not clarify?

Hmm, but looking back over the previous thread (Mar 31) I guess you
mean more in-line comments around the callbacks, presumably things
like class_dir_child_ns_type() and struct kobj_ns_type_operations
members?

It sounds like what you'd really like is to have any explicit mention
to namespaces pulled out of drivers/base (layering as you keep saying)?
But will there be a use for this outside of namespaces?  Does trying to
anticipate that fall into the category of over-abstraction?

-serge
