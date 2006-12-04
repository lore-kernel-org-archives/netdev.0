From: Dmitry Mishin <dim@openvz.org>
Subject: Re: Network virtualization/isolation
Date: Mon, 4 Dec 2006 18:19:00 +0300
Message-ID: <200612041819.01017.dim@openvz.org>
References: <453F8800.9070603@fr.ibm.com> <1165155198.3517.86.camel@localhost> <m1y7ppdl50.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	devel@openvz.org, Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Cedric Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:48968 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936997AbWLDPUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 10:20:04 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1y7ppdl50.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
> Ok.  Just a quick summary of where I see the discussion.
>
> We all agree that L2 isolation is needed at some point.
As we all agreed on this, may be it is time to send patches one-by-one?
For the beggining, I propose to resend Cedric's empty namespace patch as base 
for others - it is really empty, but necessary in order to move further.

After this patch and the following net namespace unshare patch will be 
accepted, I could send network devices virtualization patches for review and 
discussion.

What do you think?

>
> The approaches discussed for L2 and L3 are sufficiently orthogonal
> that we can implement then in either order.  You would need to
> unshare L3 to unshare L2, but if we think of them as two separate
> namespaces we are likely to be in better shape.
>
> The L3 discussion still has the problem that there has not been
> agreement on all of the semantics yet.
>
> More comments after I get some sleep.
>
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks,
Dmitry.
