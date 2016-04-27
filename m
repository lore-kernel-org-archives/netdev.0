From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 12:55:06 -0400 (EDT)
Message-ID: <20160427.125506.1088576804354580011.davem@davemloft.net>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160427095615.GA27071@breakpoint.cc>
	<20160427151336.GB1962@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcD0QzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:55:08 -0400
In-Reply-To: <20160427151336.GB1962@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 27 Apr 2016 17:14:04 +0200

> Wed, Apr 27, 2016 at 11:56:15AM CEST, fw@strlen.de wrote:
>>Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>> This patch adds the support of the 6WIND SHULTI switch. It is a software
>>> switch doing L2 forwarding.
>>> 
>>> This first version implements the minimum needed to get the device working.
>>> It also implements, via switchdev and rtnetlink, bridge forwarding offload,
>>> including FDB static entries, FDB learning and FDB ageing.
>>
>>How is this different from net/bridge?
>>How is this different from openvswitch?
> 
> The difference is that it this tries to allow userspace crap to mirror
> setting user does for bridge/ovs. Basically this looks to me like an
> attempt to enable userspace SDKs and such.

+1

There is no way I'm applying this.
