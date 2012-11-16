From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing dependent on
 IPv6 config
Date: Fri, 16 Nov 2012 13:53:41 -0500 (EST)
Message-ID: <20121116.135341.453792886356015492.davem@davemloft.net>
References: <CAEP_g=9ge1dq8ahinM075hjdfdmXaou4a9fqPyLPJQinths6pQ@mail.gmail.com>
	<50A67B44.9040508@redhat.com>
	<CAEP_g=80_P=sLkQCGXwdTLKOFN5FgqYYoDbVDXMTipbtM-GhbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, dev@openvswitch.org, netdev@vger.kernel.org,
	fengguang.wu@intel.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab2KPSxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:53:43 -0500
In-Reply-To: <CAEP_g=80_P=sLkQCGXwdTLKOFN5FgqYYoDbVDXMTipbtM-GhbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 16 Nov 2012 10:46:17 -0800

> I guess the simplest thing to do seems to just make Open vSwitch
> depend on CONFIG_INET seeing as it is practically useless without
> upper layer protocol support anyways.

The reason we have the ipv6 extension header parsing in a seperate,
always compiled statically into the kernel, module is exactly for
situations like this.

We need to think seriously if we want to go down this road of only
using INET as protection for every module that has some kind of ipv6
component to it.
