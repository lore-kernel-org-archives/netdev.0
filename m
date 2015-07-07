From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Tue, 07 Jul 2015 10:07:53 +0200
Message-ID: <1436256473.3809610.317083993.4E2A41A3@webmail.messagingengine.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
 <21611.1436179798@turing-police.cc.vt.edu>
 <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>, Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46435 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbbGGIHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 04:07:54 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id EB4D12096B
	for <netdev@vger.kernel.org>; Tue,  7 Jul 2015 04:07:53 -0400 (EDT)
In-Reply-To: <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Jul 6, 2015, at 21:44, Matteo Croce wrote:
> 2015-07-06 12:49 GMT+02:00  <Valdis.Kletnieks@vt.edu>:
> > On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
> >> Add option to disable any reply not related to a listening socket,
> >> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> >> Also disables ICMP replies to echo request and timestamp.
> >> The stealth mode can be enabled selectively for a single interface.
> >
> > A few notes.....
> >
> > 1) Do you have an actual use case where an iptables '-j DROP' isn't usable?
> 
> If you mean using a default DROP policy and allowing only the traffic
> do you want,
> then the use case is where the port can change at runtime and you may not
> want
> to update the firewall every time

Can't you use socket match in netfilter to accomplish exactly that?
