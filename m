From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [PATCH] tg3: Dont dump registers if interface not ready.
Date: Sat, 08 Oct 2011 11:21:03 +0800
Message-ID: <4E8FC19F.9060305@oracle.com>
References: <4E83D3B3.7090508@oracle.com> <4E841519.6040201@gmail.com> <20111005021423.GA2787@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Xiao Jiang <jgq516@gmail.com>, Michael Chan <mchan@broadcom.com>,
	Guru Anbalagane <guru.anbalagane@oracle.com>,
	Gurudas Pai <gurudas.pai@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Marsden <greg.marsden@oracle.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:52022 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034Ab1JHDV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 23:21:29 -0400
In-Reply-To: <20111005021423.GA2787@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>  
>>> +	/* If interface not ready then dont dump error */
>>> +	if (!netif_carrier_ok(tp->dev))
>>> +		dump = false;
> 
> Would you still experience the problem if you did the following instead
> of the above link check?
> 
> 		if (tg3_flag(tp, INIT_COMPLETE))
> 			dump = false;

I'll try it then update you.

Thanks,
Joe
