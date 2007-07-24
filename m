From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 15:43:55 +0200
Message-ID: <46A6021B.4070606@trash.net>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com> <46A48FFD.4070902@trash.net> <46A57CF3.6040505@linux.vnet.ibm.com> <46A59AAF.6090605@hartkopp.net> <46A59EDC.4060906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com,
	Thomas Gleixner <tglx@linutronix.de>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57948 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbXGXNoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 09:44:25 -0400
In-Reply-To: <46A59EDC.4060906@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan wrote:
> Oliver Hartkopp wrote:
> 
>>>>I don't think you should round down timeout values.
>>>>  
>>>>    
>>>>      
>>>
>>>Can you elaborate on that? As per the RFC of MIB ,we need only seconds
>>>granularity. Taking that as the case i dont understand why round down
>>>should not be done?
>>>  
>>>    
>>
>>When you like to create any timeout based on your calculated value, you
>>might run into the problem that your calculated value is set to _zero_
>>even if there was "some time" before the conversion. This might probably
>>not what you indented to get.
>>
>>So what about rounding up with
>>
>>return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
>>
>>???
>>
>>  
> 
> This can done.  Is this what you were ref to me, Patrick?


Yes, timeouts should usually be at least as long as specified.
