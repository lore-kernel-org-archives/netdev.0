From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion control algorithm
Date: Fri, 27 Oct 2006 13:20:28 +1300
Message-ID: <5640c7e00610261720p272fc4c2k52e062c060d8744b@mail.gmail.com>
References: <20061026224407.GA2018@c3po.0xdef.net>
	 <20061026235256.GB2018@c3po.0xdef.net>
	 <5640c7e00610261659g5816942ndaf4e09eb8110c9e@mail.gmail.com>
	 <20061026.170732.26277153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:10045 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1946052AbWJ0AUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:20:30 -0400
Received: by ug-out-1314.google.com with SMTP id 32so549789ugm
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 17:20:29 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061026.170732.26277153.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/06, David Miller <davem@davemloft.net> wrote:
> From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
> Date: Fri, 27 Oct 2006 12:59:30 +1300
>
> > I don't agree with this at all. I would love Firefox, BitTorrent etc
> > to implement usage of TCP-LP for example so they use "unused"
> > bandwidth only.
> >
> > With this change applications can't do this.
> >
> > If we are going to restrict by capabilities then I think we should
> > only restrict module loading - this way the admin of the box can
> > decide what algorithms can be used.
>
> You are using an example of a (supposedly) safe case of this
> as a justification for allowing all cases.
>
> It is bad, very bad, to allow arbitrary users to select arbitrary
> congestion control algorithms.  It is just as bad as allowing them to
> disable congestion control completely if that were an option.

OK understand your point here but I think low priority TCP has its
use. Don't agree it is just as bad, but it is bad under the wrong
circumstances - it's still better than UDP which has no congestion
control...

Don't want to make it over complicated though.

I think the most sense would be to restrict it as shown as tcp-lp is
the exception and allow tcp-lp via another mechanism. That is a
situation where the user could specify how low priority they want the
traffic to be... If I ever get enough time I'll have a go at it but
can't see it this year :-(

It actually makes more sense to tie the congestion control algorithm
to the route/destination IP if we are going to change it but that is a
whole another exercise in itself.
>
> If someone, for example, builds all the algorithms statically into
> their kernel, for testing as root, this lets all users on the machine
> do the same which is not right.
>
This is the state at present as I understand it. However that doesn't
make it right.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
