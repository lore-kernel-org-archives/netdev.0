From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Fri, 05 Dec 2008 16:43:57 -0800
Message-ID: <4939CACD.5030609@candelatech.com>
References: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org>	<4937D494.8080202@trash.net>	<4939683D.40406@candelatech.com>	<20081206092448.0c83d606.ipng@69706e6720323030352d30312d31340a.nosense.org>	<4939C269.4010609@candelatech.com> <20081205162608.43ab0864@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54356 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbYLFAoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 19:44:08 -0500
In-Reply-To: <20081205162608.43ab0864@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> Why bother, a macvlan is just a special case of a bridge, so why not
> just bridge everything?

You can add multiple mac-vlans to a single interface, but you can only
add one bridge on top of that interface.

If you need lots of (virtual) interfaces, bridges won't work as far
as I can tell.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

