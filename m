From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Fri, 18 Jan 2008 23:43:15 +0100
Message-ID: <47912B83.5010407@gmail.com>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com> <20080117111822.GB1710@ff.dom.local> <4790ACF2.1090207@miraclelinux.com> <479127C6.1080701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Makito SHIOKAWA <mshiokawa@miraclelinux.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:38911 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762565AbYARWjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 17:39:23 -0500
Received: by ug-out-1314.google.com with SMTP id z38so540272ugc.16
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:39:22 -0800 (PST)
In-Reply-To: <479127C6.1080701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 01/18/2008 11:27 PM:

> Makito SHIOKAWA wrote, On 01/18/2008 02:43 PM:

...

> @@ -1026,7 +1028,7 @@ static ssize_t bonding_store_miimon(stru
>>   				cancel_delayed_work_sync(&bond->lb_arp_work);
>>   		}
>>
>> -		if (bond->dev->flags & IFF_UP) {
>> +		if (bond->params.miimon && (bond->dev->flags & IFF_UP)) {


...similar change in bonding_store_arp_interval(), I guess?

Jarek P.
