From: Jeff Hansen <x@jeffhansen.com>
Subject: Re: [PATCH 1/1] net/unix: Allow Unix sockets to be treated like normal
 files
Date: Wed, 27 Oct 2010 20:50:17 -0600
Message-ID: <4CC8E4E9.2060209@jeffhansen.com>
References: <1288232669-8927-1-git-send-email-x@jeffhansen.com> <20101027.193212.193709254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49717 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932744Ab0J1CuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 22:50:23 -0400
In-Reply-To: <20101027.193212.193709254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Dave,

I agree that on larger systems this doesn't really make sense, but on 
embedded platforms this can save some code space since applications can 
get rid of their FIFO listeners and have strictly socket listeners.  
That's why I made it an option that could be disabled by default.

Do you know who originally suggested that "creepy crawlies" are 
introduced by allowing sockets to be opened?  I'd be interested to know 
how this could affect security, if at all.

-Jeff

On 10/27/2010 08:32 PM, David Miller wrote:
> From: x@jeffhansen.com
> Date: Thu, 28 Oct 2010 02:24:29 +0000
>
>> Resent.  Is there anything else I need to do for this patch to get reviewed
>> and/or merged?  Any comments by anyone?
> I don't like this idea at all.
>
> I remember there is a reason why similar things are not allowed for
> sockets, it causes all sorts of problems although I forget the exact
> details.
>
> Take a look at net/socket.c:sock_no_open(), for example.
>


-- 
---------------------------------------------------
"If someone's gotta do it, it might as well be me."
                 x@jeffhansen.com

