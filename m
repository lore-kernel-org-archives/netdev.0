From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 11:34:35 +0200
Message-ID: <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59748 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751645AbcEUJeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 05:34:37 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 225FC20A40
	for <netdev@vger.kernel.org>; Sat, 21 May 2016 05:34:36 -0400 (EDT)
In-Reply-To: <20160521015604.GD2452@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2016, at 03:56, Sowmini Varadhan wrote:
> On (05/21/16 02:20), Hannes Frederic Sowa wrote:
> > 
> > There are some options inherently protocol depending like the jumbo
> > payload option, which should be under control of the kernel, or the
> > router alert option for igmp, which causes packets to be steered towards
> > the slow/software path of routers, which can be used for DoS attacks.
> > 
> > Setting CALIPSO options in IPv6 on packets as users would defeat the
> > whole CALIPSO model, etc.
> > 
> > The RFC3542 requires at least some of the options in dst/hop-by-hop
> 
> "requires" is a strong word. 3542 declares it as a  "may" (lower case).
> The only thing required strongly is IPV6_NEXTHOP itself.
> 
> I suspect 3542 was written at a time when hbh and dst opt were loosely
> defined and the "may" is just a place-holder (i.e., it's not even a MAY)

My wording directly from the RFC was too strong, true, but given that
there is a CALIPSO patch already floating around for the kernel and
those options are strictly controlled by selinux policy and build the
foundation for the networking separation we can't make it simply
non-priv.

Bye,
Hannes
