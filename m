From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: Network virtualization/isolation
Date: Mon, 4 Dec 2006 17:43:32 +0100
Message-ID: <20061204164332.GA11687@MAIL.13thfloor.at>
References: <453F8800.9070603@fr.ibm.com> <1165155198.3517.86.camel@localhost> <m1y7ppdl50.fsf@ebiederm.dsl.xmission.com> <200612041819.01017.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:37640 "EHLO
	MAIL.13thfloor.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937121AbWLDQpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:45:09 -0500
To: Dmitry Mishin <dim@openvz.org>
Content-Disposition: inline
In-Reply-To: <200612041819.01017.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 06:19:00PM +0300, Dmitry Mishin wrote:
> On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
> > Ok.  Just a quick summary of where I see the discussion.
> >
> > We all agree that L2 isolation is needed at some point.

> As we all agreed on this, may be it is time to send patches
> one-by-one? For the beggining, I propose to resend Cedric's 
> empty namespace patch as base for others - it is really empty, 
> but necessary in order to move further.
> 
> After this patch and the following net namespace unshare 
> patch will be accepted, 

well, I have neither seen any performance tests showing
that the following is true:

 - no change on network performance without the 
   space enabled
 - no change on network performance on the host
   with the network namespaces enabled
 - no measureable overhead inside the network
   namespace 
 - good scaleability for a larger number of network
   namespaces 

> I could send network devices virtualization patches for
> review and discussion.

that won't hurt ...

best,
Herbert

> What do you think?
> 
> > The approaches discussed for L2 and L3 are sufficiently orthogonal
> > that we can implement then in either order.  You would need to
> > unshare L3 to unshare L2, but if we think of them as two separate
> > namespaces we are likely to be in better shape.
> >
> > The L3 discussion still has the problem that there has not been
> > agreement on all of the semantics yet.
> >
> > More comments after I get some sleep.
> >
> > Eric
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Thanks,
> Dmitry.
> _______________________________________________
> Containers mailing list
> Containers@lists.osdl.org
> https://lists.osdl.org/mailman/listinfo/containers
