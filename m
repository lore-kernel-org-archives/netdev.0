From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sun, 10 Sep 2006 04:47:09 +0200
Message-ID: <20060910024709.GA13157@MAIL.13thfloor.at>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609081710.09124.dim@openvz.org> <20060908181154.GA8745@MAIL.13thfloor.at> <200609091157.24734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:12971 "EHLO
	MAIL.13thfloor.at") by vger.kernel.org with ESMTP id S965097AbWIJCrK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 22:47:10 -0400
To: Dmitry Mishin <dim@openvz.org>
Content-Disposition: inline
In-Reply-To: <200609091157.24734.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 09, 2006 at 11:57:24AM +0400, Dmitry Mishin wrote:
> On Friday 08 September 2006 22:11, Herbert Poetzl wrote:
> > actually the light-weight ip isolation runs perfectly
> > fine _without_ CAP_NET_ADMIN, as you do not want the
> > guest to be able to mess with the 'configured' ips at
> > all (not to speak of interfaces here)

> It was only an example. I'm thinking about how to implement flexible
> solution, which permits light-weight ip isolation as well as
> full-fledged netwrok virtualization. Another solution is to split
> CONFIG_NET_NAMESPACE. Is it good for you?

well, I think it would be best to have both, as
they are complementary to some degree, and IMHO
both, the full virtualization _and_ the isolation
will require a separate namespace to work, I also
think that limiting the isolation to something
very simple (like one IP + network or so) would
be acceptable for a start, because especially
multi IP or network range checks require a little
more efford to get them right ...

I do not think that folks would want to recompile
their kernel just to get a light-weight guest or
a fully virtualized one

best,
Herbert

> -- 
> Thanks,
> Dmitry.
