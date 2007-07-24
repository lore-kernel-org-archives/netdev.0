From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 19:20:48 +0530
Message-ID: <46A603B8.6080308@linux.vnet.ibm.com>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com> <46A48FFD.4070902@trash.net> <46A57CF3.6040505@linux.vnet.ibm.com> <46A59AAF.6090605@hartkopp.net> <46A59EDC.4060906@linux.vnet.ibm.com> <46A6021B.4070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com,
	Thomas Gleixner <tglx@linutronix.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:53024 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480AbXGXNup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 09:50:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6ODoi7a028532
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 09:50:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6ODoijD404548
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 09:50:44 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6ODohGi012578
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 09:50:44 -0400
In-Reply-To: <46A6021B.4070606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Varun Chandramohan wrote:
>   
>> Oliver Hartkopp wrote:
>>
>>     
>>>>> I don't think you should round down timeout values.
>>>>>  
>>>>>    
>>>>>      
>>>>>           
>>>> Can you elaborate on that? As per the RFC of MIB ,we need only seconds
>>>> granularity. Taking that as the case i dont understand why round down
>>>> should not be done?
>>>>  
>>>>    
>>>>         
>>> When you like to create any timeout based on your calculated value, you
>>> might run into the problem that your calculated value is set to _zero_
>>> even if there was "some time" before the conversion. This might probably
>>> not what you indented to get.
>>>
>>> So what about rounding up with
>>>
>>> return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
>>>
>>> ???
>>>
>>>  
>>>       
>> This can done.  Is this what you were ref to me, Patrick?
>>     
>
>
> Yes, timeouts should usually be at least as long as specified.
>   
Thanks Patrick and Oliver, ill round it up. :-)

