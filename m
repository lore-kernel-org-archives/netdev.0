From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 1/7] bna: Code Cleanup and Enhancements
Date: Mon, 10 Dec 2012 16:39:15 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B5B0B9CFD2@HQ1-EXCH01.corp.brocade.com>
References: <1355175725-19202-1-git-send-email-rmody@brocade.com>
	<1355175725-19202-2-git-send-email-rmody@brocade.com>
 <20121210.171349.1368932708858713762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46343 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751395Ab2LKAjZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 19:39:25 -0500
In-Reply-To: <20121210.171349.1368932708858713762.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, December 10, 2012 2:14 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Mon, 10 Dec 2012 13:41:59 -0800
>
>> -		skb = unmap_array[unmap_cons].skb;
>> -		BUG_ON(!(skb));
>> -		unmap_array[unmap_cons].skb = NULL;
>> +		curr_ua = &unmap_array[unmap_cons];
>> +
>> +		skb = curr_ua->skb;
>> +		BUG_ON(!(skb));\
>                               ^^^
>
>Really?
>
>Please carefully review your own work before submitting it for
>inclusion.  When you have erroneous things like this in the very first
>patch it reflects very poorly upon the quality of your work.

Sorry Dave, it accidentally got introduced. I will rectify it and resend the patches after carefully reviewing patches for similar errors.

Thanks
Rasesh
