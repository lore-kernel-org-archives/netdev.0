From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: add per bridge device controls for invoking
 iptables
Date: Wed, 30 Jun 2010 14:27:17 -0700 (PDT)
Message-ID: <20100630.142717.123424464.davem@davemloft.net>
References: <1277729220-11775-1-git-send-email-kaber@trash.net>
	<20100630142440.68adfdb1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757274Ab0F3V1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:27:04 -0400
In-Reply-To: <20100630142440.68adfdb1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 30 Jun 2010 14:24:40 -0700

> On Mon, 28 Jun 2010 14:47:00 +0200
> kaber@trash.net wrote:
> 
>> From: Patrick McHardy <kaber@trash.net>
>> 
>> Support more fine grained control of bridge netfilter iptables invocation
>> by adding seperate brnf_call_*tables parameters for each device using the
>> sysfs interface. Packets are passed to layer 3 netfilter when either the
>> global parameter or the per bridge parameter is enabled.
>> 
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Looks like a good idea.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: David S. Miller <davem@davemloft.net>

Patrick since this is mostly netfilter'ish, please toss it into one
of your trees.

Thanks!
