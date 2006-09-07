From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Thu, 07 Sep 2006 13:50:55 -0600
Message-ID: <m1pse7o3q8.fsf@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060816115313.GC31810@sergelap.austin.ibm.com>
	<44FD7CF0.4030009@fr.ibm.com>
	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>
	<20060905165328.GA17317@MAIL.13thfloor.at>
	<44FE907F.7090508@fr.ibm.com>
	<20060906165642.GA26202@MAIL.13thfloor.at>
	<44FF0760.1040600@openvz.org>
	<m1y7swvo6k.fsf_-_@ebiederm.dsl.xmission.com> <45004799.70000@sw.ru>
	<20060907172759.GB25118@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>, Kir Kolyshkin <kir@openvz.org>,
	Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51649 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1751679AbWIGTv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 15:51:58 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060907172759.GB25118@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Thu, 7 Sep 2006 19:27:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

> On Thu, Sep 07, 2006 at 08:23:53PM +0400, Kirill Korotaev wrote:
>
> well, who said that you need to have things like RAW sockets
> or other protocols except IP, not to speak of iptable and 
> routing entries ...
>
> folks who _want_ full network virtualization can use the
> more complete virtual setup and be happy ...

Exactly this was a proposal for isolation for containers
that don't get CAP_NET_ADMIN, with a facility that could
easily be general purpose.

Eric
