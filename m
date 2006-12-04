From: Dmitry Mishin <dim@openvz.org>
Subject: Re: Network virtualization/isolation
Date: Mon, 4 Dec 2006 20:02:48 +0300
Message-ID: <200612042002.49094.dim@openvz.org>
References: <453F8800.9070603@fr.ibm.com> <200612041819.01017.dim@openvz.org> <20061204164332.GA11687@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:47742 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937196AbWLDRDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 12:03:19 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061204164332.GA11687@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 December 2006 19:43, Herbert Poetzl wrote:
> On Mon, Dec 04, 2006 at 06:19:00PM +0300, Dmitry Mishin wrote:
> > On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
> > > Ok.  Just a quick summary of where I see the discussion.
> > >
> > > We all agree that L2 isolation is needed at some point.
> >
> > As we all agreed on this, may be it is time to send patches
> > one-by-one? For the beggining, I propose to resend Cedric's
> > empty namespace patch as base for others - it is really empty,
> > but necessary in order to move further.
> >
> > After this patch and the following net namespace unshare
> > patch will be accepted,
>
> well, I have neither seen any performance tests showing
> that the following is true:
>
>  - no change on network performance without the
>    space enabled
>  - no change on network performance on the host
>    with the network namespaces enabled
>  - no measureable overhead inside the network
>    namespace
>  - good scaleability for a larger number of network
>    namespaces
These questions are for complete L2 implementation, not for these 2 empty 
patches. If you need some data relating to Andrey's implementation, I'll get 
it. Which test do you accept?
 
>
> > I could send network devices virtualization patches for
> > review and discussion.
>
> that won't hurt ...
>
> best,
> Herbert
>
> > What do you think?
> >
> > > The approaches discussed for L2 and L3 are sufficiently orthogonal
> > > that we can implement then in either order.  You would need to
> > > unshare L3 to unshare L2, but if we think of them as two separate
> > > namespaces we are likely to be in better shape.
> > >
> > > The L3 discussion still has the problem that there has not been
> > > agreement on all of the semantics yet.
> > >
> > > More comments after I get some sleep.
> > >
> > > Eric
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > --
> > Thanks,
> > Dmitry.
> > _______________________________________________
> > Containers mailing list
> > Containers@lists.osdl.org
> > https://lists.osdl.org/mailman/listinfo/containers

-- 
Thanks,
Dmitry.
