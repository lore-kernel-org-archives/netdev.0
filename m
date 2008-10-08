From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 08 Oct 2008 16:32:29 +0400
Message-ID: <48ECA85D.1050809@openvz.org>
References: <20081008081109.GA25342@1wt.eu> <48ECA4AC.1010101@openvz.org> <20081008122645.GB28783@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47224 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbYJHMdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 08:33:14 -0400
In-Reply-To: <20081008122645.GB28783@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau wrote:
> Hi Pavel,
> 
> On Wed, Oct 08, 2008 at 04:16:44PM +0400, Pavel Emelyanov wrote:
>>> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
>>> index d0437f3..0e23062 100644
>>> --- a/include/linux/sysctl.h
>>> +++ b/include/linux/sysctl.h
>>> @@ -435,6 +435,7 @@ enum
>>>  	NET_TCP_ALLOWED_CONG_CONTROL=123,
>>>  	NET_TCP_MAX_SSTHRESH=124,
>>>  	NET_TCP_FRTO_RESPONSE=125,
>>> +	NET_TCP_SIMULT_CONNECT=126,
>> Minor - sysctl syscall (as long as numbers and ->strategy callbacks) are
>> about to be removed some time, so new sysctls are to be CTL_UNNUMBERED.
> 
> I noticed that one in the two latest UDP sysctls, but was not aware of the
> rules related to its use. Given the number of unconverted sysctls, is it
> worth changing it now ?

Sorry, I don't get you here. Sysctls are not supposed to get converted,
the intention is just to a) stop adding new sysctls with strategies and
b) drop all the existing strategies in the future.

> Willy
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

