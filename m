From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH next-next v4 0/2] MPLS: Add limited GSO support
Date: Sat, 25 May 2013 09:02:44 +0900
Message-ID: <20130525000244.GA32093@verge.net.au>
References: <1369378295-17779-1-git-send-email-horms@verge.net.au>
 <CAEH94Litbbgya=YPyDUDkQZnV2Rod=EwwUZDfgq2f4J77a8wew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53825 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab3EYACs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 20:02:48 -0400
Content-Disposition: inline
In-Reply-To: <CAEH94Litbbgya=YPyDUDkQZnV2Rod=EwwUZDfgq2f4J77a8wew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 03:12:33PM +0800, Zhi Yong Wu wrote:
> HI,
> 
>    By the way, will this label is allocated statically or via
> auto-negotiation between two switches such as LDP?

Hi,

The support that I have been working on is for Open vSwtich.
As such the label is added by Open vSwtich which may be configured in
a variety of ways including static configuration using ovs-odpctl
and dynamic configuration using an Open Flow controller.

However, this small patch-set only adds limited GSO support for MPLS.
It does not handle manipulation of labels.
