From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 03/10] Move two functions.
Date: Mon, 01 Oct 2007 13:46:58 -0700
Message-ID: <47015CC2.6020402@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <1191019977559-git-send-email-bugfood-ml@fatooh.org> <4700F5AC.9020609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41599 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbXJAUrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:04 -0400
In-Reply-To: <4700F5AC.9020609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Move sfq_q_destroy() to above sfq_q_init() so that it can be used
>> by an error case in a later patch.
>>
>> Move sfq_destroy() as well, for clarity.
> 
> 
> This patch looks pointless, just put them where you need them
> in the patch introducing them.

As you wish. I thought having a separate patch would ease reviewing.

-Corey
