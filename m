From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: Re: [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in tcp_v4_conn_request()
Date: Thu, 24 Jan 2013 23:41:54 -0800
Message-ID: <51023742.2000908@gmail.com>
References: <1359097408-9786-1-git-send-email-niv@us.ibm.com> <CAGK4HS8ABKqa8J1Sd1Q52P4p3=KcSokQQX0e90FWV6aZsVdP3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Leandro Lucarella <leandro.lucarella@sociomantic.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:48065 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab3AYHmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 02:42:00 -0500
Received: by mail-ie0-f182.google.com with SMTP id s9so11991iec.13
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 23:42:00 -0800 (PST)
In-Reply-To: <CAGK4HS8ABKqa8J1Sd1Q52P4p3=KcSokQQX0e90FWV6aZsVdP3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2013 11:29 PM, Vijay Subramanian wrote:
> On 24 January 2013 23:03, Nivedita Singhvi <niveditasinghvi@gmail.com> wrote:
>> We drop a connection request if the accept backlog, syn queue are full when processing reaches tcp_v4_conn_request(). Increment the appropriate counter so this isn't silent, for accurate stats and help in debugging.
>>
> 
> Commit message seems misleading. syn queue is not really full at this
> point. It just has more than enough entries.

Er, good point. I should have said "sufficiently full" or "warm 
enough to warrant starting drops" - hope I'm not confusing 
things further, am I? DaveM, would you like me to resend, if you're 
picking this up? 


thanks,
Nivedita
