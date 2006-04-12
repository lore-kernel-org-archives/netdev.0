From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFD][PATCH] typhoon and core sample for folding away VLAN stuff
Date: Wed, 12 Apr 2006 13:10:06 -0700
Message-ID: <443D5E9E.80002@candelatech.com>
References: <200604071628.30486.vda@ilport.com.ua> <200604111502.52302.vda@ilport.com.ua> <200604111517.37215.netdev@axxeo.de> <200604122132.46113.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <netdev@axxeo.de>, Denis Vlasenko <vda@ilport.com.ua>,
	Dave Dillow <dave@thedillows.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33771 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932177AbWDLULt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 16:11:49 -0400
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200604122132.46113.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What is the reasoning for this change?  Is the compiler
able to optomize the right-hand-side to a constant with your
change in place?

> -	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
> +	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
>  		return -EINVAL;
>  	}




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

