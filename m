From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 07:16:24 -0400
Message-ID: <461B7208.9030409@pobox.com>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net> <1176202930.8459.81.camel@johannes.berg> <461B7060.8000407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org,
	kuznet@ms2.inr.ac.ru, shemminger@linux-foundation.org,
	greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34720 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753729AbXDJLQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 07:16:53 -0400
In-Reply-To: <461B7060.8000407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Maybe not wireless, but bonding, briding, vlan, etun, possibly more.

[if I understand you correctly] I agree.  With ethtool, the idea is to 
have a single tool that supports multiple hardware platforms -- even to 
the point of introducing hardware-specific code into ethtool.

While I agree with wireless-dev that wireless /needs/ a separate tool, 
for things like bridging and vlan it would certainly be nice to mitigate 
the tool count explosion.

	Jeff


