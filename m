From: Ron Angeles <ronangeles@gmail.com>
Subject: Re: [PATCH net-next] net: atl1c: add BQL support
Date: Wed, 12 Aug 2015 22:12:08 -0700
Message-ID: <55CC2728.6020309@gmail.com>
References: <55CAE130.8040406@gmail.com>
 <20150812224020.GA31826@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35446 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbHMFMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 01:12:10 -0400
Received: by pdrg1 with SMTP id g1so15036327pdr.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 22:12:09 -0700 (PDT)
In-Reply-To: <20150812224020.GA31826@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2015 03:40 PM, Francois Romieu wrote:
> Ron Angeles <ronangeles@gmail.com> :
>> This BQL implementation is mostly derived from its related driver, alx.
>> Tested on AR8131 (rev c0) [1969:1063]. Saturated a 100mbps link with 5
>> concurrent runs of netperf. Ping latency dropped from 14ms to 3ms.
>
> Could you use some time to test the attached experimental stuff as well ?
>

I only have one of these NICs and it is running on something critical 
throughout the weekdays. I can try running these when I have time on a 
weekend. Is there any particular way you would suggest testing? Would an 
overnight smoke test with netperf suffice?

-Ron
