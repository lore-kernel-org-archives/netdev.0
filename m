From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 15/29: nf_conntrack: connection tracking helper name
 persistent aliases
Date: Thu, 27 Nov 2008 19:33:31 +0100
Message-ID: <492EE7FB.6020905@trash.net>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161523.13891.6192.sendpatchset@x2.localnet> <alpine.LNX.1.10.0811271930061.21626@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56214 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbYK0Sdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 13:33:33 -0500
In-Reply-To: <alpine.LNX.1.10.0811271930061.21626@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Thursday 2008-11-27 17:15, Patrick McHardy wrote:
>>    
>>    This patch adds the macro MODULE_ALIAS_NFCT_HELPER that defines a
>>    way to provide generic and persistent aliases for the connection
>>    tracking helpers.
> 
> I wonder a bit. iptables is fine with loading ipt_%s (mapped to xt_%s),
> but conntrack requires an nfct-help-%s namespace and cannot use
> nf_conntrack_%s?
> Of course it makes sense to use a separate namespace - especially
> in light of the nf_conntrack_ prefix used by both helpers and
> protos, but I'm still asking.
>

Please CC the people that can actually answer this question.
