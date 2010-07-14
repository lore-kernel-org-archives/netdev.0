From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [RFC PATCH]: Fix a warning in the niu driver
Date: Wed, 14 Jul 2010 14:26:34 -0400
Message-ID: <4C3E015A.5030705@redhat.com>
References: <4C3514ED.2060904@redhat.com>	<20100707.170820.146356362.davem@davemloft.net>	<4C3DB927.2060106@redhat.com> <20100714.112800.189702548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264Ab0GNS2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 14:28:54 -0400
In-Reply-To: <20100714.112800.189702548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/14/2010 02:28 PM, David Miller wrote:
> From: Prarit Bhargava <prarit@redhat.com>
> Date: Wed, 14 Jul 2010 09:18:31 -0400
>
>   
>> Dave, would it be acceptable if I then wrapped link in
>> uninitialized_var() to get rid of the warning I'm trying to resolve?  It
>> seems that your patch then checks for a valid page value so it should be
>> okay.
>>     
> If the patch I posted doesn't fix your warning, the compiler is broken.
>
>   

Oops -- my bad.  I think I fat fingered something.  Your patch
absolutely fixes the warning.  Thanks Dave.

P.
