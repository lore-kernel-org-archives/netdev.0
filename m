From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: patch sysfs-implement-sysfs-tagged-directory-support.patch
 added to gregkh-2.6 tree
Date: Fri, 30 Apr 2010 10:43:21 -0500
Message-ID: <20100430154320.GC13977@us.ibm.com>
References: <12725729473590@kroah.org>
 <4BDA5A2D.6080904@kernel.org>
 <20100430044522.GA29845@suse.de>
 <m1aaslbjh4.fsf@fess.ebiederm.org>
 <4BDA6C90.9010303@kernel.org>
 <20100430142940.GC7187@us.ibm.com>
 <4BDAF5B0.3080801@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>, bcrl@lhnet.ca,
	benjamin.thery@bull.net, cornelia.huck@de.ibm.com,
	eric.dumazet@gmail.com, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:44974 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423Ab0D3Qq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 12:46:56 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3UBOgk4029443
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 07:24:42 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3UFhOGp172940
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:43:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3UFhMgS019206
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:43:23 -0300
Content-Disposition: inline
In-Reply-To: <4BDAF5B0.3080801@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Tejun Heo (tj@kernel.org):
> Hello,
> 
> On 04/30/2010 04:29 PM, Serge E. Hallyn wrote:
> > Hmm, but looking back over the previous thread (Mar 31) I guess you
> > mean more in-line comments around the callbacks, presumably things
> > like class_dir_child_ns_type() and struct kobj_ns_type_operations
> > members?
> 
> In-line.  What they're, how they're supposed to be used, which calling
> context is expected, what can be returned and so on.
> 
> > It sounds like what you'd really like is to have any explicit
> > mention to namespaces pulled out of drivers/base (layering as you
> > keep saying)?  But will there be a use for this outside of
> > namespaces?  Does trying to anticipate that fall into the category
> > of over-abstraction?
> 
> I wouldn't mind limited amount of layering exceptions as long as
> they're clearly documented.  What I'm primarily worried about is not
> the possibility of other users but more the obfuscation of the whole
> sysfs-kobject-driver model thing which is already overly abstracted
> and obfuscated (at least it seems to me that way).
> 
> NS needs tagged support in the driver model which in itself is fine
> and I also understand that from someone who's primarily working on NS,
> adding a bit on top of the whole thing wouldn't seem like much of a
> problem.  To me it seems like worsening a problem which is already
> pretty bad.  I hope you could understand my POV too.

I do.  I can take a stab monday at pushing a cloned version of Eric's
tree with comments added, if Eric doesn't have time.  (Or a patch on
top of Greg's tree)

thanks,
-serge
