From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 17:14:04 +0200
Message-ID: <20160427151336.GB1962@nanopsycho.orion>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35106 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbcD0POI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:14:08 -0400
Received: by mail-wm0-f52.google.com with SMTP id e201so43607962wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 08:14:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160427095615.GA27071@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 27, 2016 at 11:56:15AM CEST, fw@strlen.de wrote:
>Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>> This patch adds the support of the 6WIND SHULTI switch. It is a software
>> switch doing L2 forwarding.
>> 
>> This first version implements the minimum needed to get the device working.
>> It also implements, via switchdev and rtnetlink, bridge forwarding offload,
>> including FDB static entries, FDB learning and FDB ageing.
>
>How is this different from net/bridge?
>How is this different from openvswitch?

The difference is that it this tries to allow userspace crap to mirror
setting user does for bridge/ovs. Basically this looks to me like an
attempt to enable userspace SDKs and such.
