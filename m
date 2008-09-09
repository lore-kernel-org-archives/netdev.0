From: Paul Larson <pl@us.ibm.com>
Subject: Re: [PATCH] bnx2x: EEH recovery fix
Date: Tue, 09 Sep 2008 16:08:18 -0500
Message-ID: <48C6E5C2.20905@us.ibm.com>
References: <BD3F7F1EFBA6D54DB056C4FFA45140080334A46036@SJEXCHCCR01.corp.ad.broadcom.com> <20080908.124743.30466861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	yitchak.gertner@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50966 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbYIIVJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 17:09:17 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m89L9Gko004417
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 17:09:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89L9BeW174328
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 17:09:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89L9AHm017961
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 17:09:11 -0400
In-Reply-To: <20080908.124743.30466861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Mon, 8 Sep 2008 03:22:32 -0700
>
>   
>> The EEH mechanism caused a fatal error when using the bnx2x since
>> the driver attempted accessing the device after it was reset by the
>> EEH. This patch sets a proper unload when EEH error is detected
>> without accessing the device.
>>
>> Since the current implementation causes a fatal error, I ask that
>> you will consider applying this patch.
>>     
>
> What user has run into and reported this failure, and is it
> a regression compared to 2.6.26?
>
> That is the criteria for my putting this patch in now.
>
> Since EEH triggers are an exceedingly corner case error condition,
> this puts this patch even less valid to go in outside of the merge
> window.
Just in case it's lack of testing you were concerned with, I can say 
that I've tested this patch on power and it does fix our eeh handling 
for bnx2x.

Thanks,
Paul Larson
