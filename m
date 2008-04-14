From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
	prior to interface-up
Date: Mon, 14 Apr 2008 06:01:14 +0000
Message-ID: <20080414060114.GA4016@ff.dom.local>
References: <20080413.224433.243167397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pebolle@tiscali.nl, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, jgarzik@redhat.com,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:34969 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbYDNF6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:58:38 -0400
Received: by ug-out-1314.google.com with SMTP id z38so395574ugc.16
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 22:58:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080413.224433.243167397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-04-2008 07:44, David Miller wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
> Date: Thu, 10 Apr 2008 17:00:17 +0200
> 
>> From: Paul Bolle <pebolle@tiscali.nl>
>>    
>> Commit bada339 (Validate device addr prior to interface-up) caused a regression
>> in the ISDN network code, see: http://bugzilla.kernel.org/show_bug.cgi?id=9923
>> The trivial fix is to remove the pointer to eth_validate_addr() in the
>> net_device struct in isdn_net_init().
>>     
>> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> 
> Applied, thanks a lot Paul.

Maybe I missed Patrick point, but it seems this patch isn't good:
it omits address validation hiding possible problems.

Regards,
Jarek P.

