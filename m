From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/4] switchdev: don't support custom ip
 rules, for now
Date: Mon, 02 Mar 2015 15:10:23 -0500 (EST)
Message-ID: <20150302.151023.1951758875495736687.davem@davemloft.net>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com>
	<1425290777-22702-5-git-send-email-sfeldma@gmail.com>
	<54F4755F.6020205@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404AbbCBUKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:10:25 -0500
In-Reply-To: <54F4755F.6020205@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Mon, 02 Mar 2015 06:36:15 -0800

> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Keep switchdev FIB offload model simple for now and don't allow custom
>> ip
>> rules.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> 
> I don't see a need to do this. And seems very aggressive.
> Also, note that the rules in a system can be on non-hw accelerated
> ports.
> 
> Until rules are hw accelerated, its ok to document this limitation for
> hw accelerated routes in my opinion.

No, we absolutely must start with a simple model that doesn't try
at all to offload if any FIB rules are installed.
