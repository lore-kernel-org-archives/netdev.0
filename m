From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Fri, 8 Sep 2006 20:11:54 +0200
Message-ID: <20060908181154.GA8745@MAIL.13thfloor.at>
References: <20060815182029.A1685@castle.nmd.msu.ru> <45004799.70000@sw.ru> <20060907172759.GB25118@MAIL.13thfloor.at> <200609081710.09124.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:8345 "EHLO
	MAIL.13thfloor.at") by vger.kernel.org with ESMTP id S1751019AbWIHSLz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 14:11:55 -0400
To: Dmitry Mishin <dim@openvz.org>
Content-Disposition: inline
In-Reply-To: <200609081710.09124.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2006 at 05:10:08PM +0400, Dmitry Mishin wrote:
> On Thursday 07 September 2006 21:27, Herbert Poetzl wrote:
> > well, who said that you need to have things like RAW sockets
> > or other protocols except IP, not to speak of iptable and
> > routing entries ...
> >
> > folks who _want_ full network virtualization can use the
> > more complete virtual setup and be happy ...

> Let's think about how to implement this.

> As I understood VServer's design, your proposal is to split
> CAP_NET_ADMIN to multiple capabilities and use them if required. So,
> for your light-weight container it is enough to implement context
> isolation for protected by CAP_NET_IP capability (for example) code
> and put 'if (!capable(CAP_NET_*))' checks to all other places. 

actually the light-weight ip isolation runs perfectly
fine _without_ CAP_NET_ADMIN, as you do not want the
guest to be able to mess with the 'configured' ips at
all (not to speak of interfaces here)

best,
Herbert

> But this could be easily implemented over OpenVZ code by
> CAP_VE_NET_ADMIN split.
> 
> So, the question is:
> Could you point out the places in Andrey's implementation of network
> namespaces, which prevents you to add CAP_NET_ADMIN separation later?
> 
> -- 
> Thanks,
> Dmitry.
