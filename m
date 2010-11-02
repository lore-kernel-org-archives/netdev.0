From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 02 Nov 2010 21:16:54 +0100
Message-ID: <4CD071B6.7030202@hartkopp.net>
References: <1288722503.2504.14.camel@dan>  <4CD069D4.7010801@hartkopp.net> <1288727605.2504.21.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:11116 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0KBURB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 16:17:01 -0400
In-Reply-To: <1288727605.2504.21.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2010 20:53, Dan Rosenberg wrote:
> 
>> Why is this bad? Can the addresses of CAN-BCM sock structs be used for
>> anything from userspace?
>>
>> For me they are just intended to be unique numbers ...
>>
> 
> This is a bad idea because it makes exploiting other kernel
> vulnerabilities easier.  Exposing the address of an object in a slab
> cache, especially an object that unprivileged users have some level of
> control of, is just an invitation to use that structure when writing
> exploits, for heap overflows or otherwise.

The "level of control of" is just creating a socket or not. None of the data
in the created struct can be influenced by an unprivileged user.
Btw. i can generally follow your concerns after this explanation.

I'm going to check the kernel src for other approaches to display unique
numbers in procfs and will send a patch that takes care.

Thanks,
Oliver
