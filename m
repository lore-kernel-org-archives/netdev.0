From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 22:53:08 +0200
Message-ID: <44FF3534.1060102@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com>	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>	<20060905165328.GA17317@MAIL.13thfloor.at>	<44FE907F.7090508@fr.ibm.com>	<20060906165642.GA26202@MAIL.13thfloor.at>	<44FF0760.1040600@openvz.org>	<m1y7swvo6k.fsf_-_@ebiederm.dsl.xmission.com> <44FF1A47.1030900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49065 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751412AbWIFUxP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 16:53:15 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k86KrEfG017163
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:53:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86KrEFH278088
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 14:53:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86KrD4F022784
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 14:53:13 -0600
To: Kir Kolyshkin <kir@openvz.org>
In-Reply-To: <44FF1A47.1030900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kir Kolyshkin wrote:

<snip>

> I am not sure about "network isolation" (used by Linux-VServer), but as 
> it comes for level2 vs. level3 virtualization, I see a need for both. 
> Here is the easy-to-understand comparison which can shed some light: 
> http://wiki.openvz.org/Differences_between_venet_and_veth

thanks kir,

> Here are a couple of examples
> * Do we want to let container's owner (i.e. root) to add/remove IP 
> addresses? Most probably not, but in some cases we want that.
> * Do we want to be able to run DHCP server and/or DHCP client inside a 
> container? Sometimes...but not always.
> * Do we want to let container's owner to create/manage his own set of 
> iptables? In half of the cases we do.
> 
> The problem here is single solution will not cover all those scenarios.

some would argue that there is one single solution : Xen or similar.

IMO, I think containers should try to leverage their difference,
performance, and not try to simulate a real hardware environment.

Restricting the network environment of a container should be considered
acceptable if this is for the sake of performance. The network interface(s)
could be pre-configured and provided to the container. Protocol(s) could be
forbidden.

Now, if you need more network power in a container, you will need a real or
a virtualized interface.

But let's consider both alternatives.

thanks,

C.
