From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [RFC PATCH] xfrm: avoid to send/receive the exceeding hard
 lifetime data
Date: Sat, 15 Dec 2012 09:36:27 +0800
Message-ID: <CAJFZqHyRTW5eShGzLVzkHTDAeopwC5L6wS=Cfh_DTa82DE2s1g@mail.gmail.com>
References: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
	<20121213101422.GF18940@secunet.com>
	<CAJFZqHyUSHS3-TjkGQ3WiD486MCCTbiRd4vXUAcbJ=ZqqsnQoA@mail.gmail.com>
	<20121214113945.GH18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:43969 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOBg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 20:36:27 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so4985845vcd.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 17:36:27 -0800 (PST)
In-Reply-To: <20121214113945.GH18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/14 Steffen Klassert <steffen.klassert@secunet.com>:
> On Fri, Dec 14, 2012 at 02:58:03PM +0800, RongQing Li wrote:
>>
>> Yes, RFC does not say how to handle this packet.
>>
>> But when I do a IPsec compliance test with IxANVL, the test case 5.3/5.11,
>> which reports a error because it expects this packet should be dropped, but not.
>>
>>
>> I do not know if it is bug, or if it is valuable to fix it?
>>
>
> As long as the RFC does not state anything else, we ar ok in the
> synchronous code path. But we need a fix for the asynchronous
> code path.
>

Thanks.

-Roy
