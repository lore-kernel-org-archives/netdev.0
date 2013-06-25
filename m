From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 19:12:43 +0200
Message-ID: <51C9CF8B.6030502@freebox.fr>
References: <51C9BB9C.4050405@freebox.fr>  <1372176951.3301.103.camel@edumazet-glaptop> <51C9C4FF.1020706@freebox.fr>  <1372179447.3301.105.camel@edumazet-glaptop> <1372179933.3301.106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns0.vlq16.iliad.fr ([213.36.7.21]:60492 "EHLO
	ns0.vlq16.iliad.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab3FYRMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 13:12:45 -0400
In-Reply-To: <1372179933.3301.106.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 07:05 PM, Eric Dumazet wrote:
> On Tue, 2013-06-25 at 09:57 -0700, Eric Dumazet wrote:
>
>> I am not sure it's needed, because the writer holds a spinlock and is
>> not allowed to sleep or being preempted.
>>
>> If it's needed, there is a bug somewhere else...
>
> Oh well, its a write_seqcount, so no spinlock...

That's what I was going to reply.

Am I right in thinking that the process spinning on SIOCGIFNAME should be 
naturally be preempted by other tasks by the scheduler once its timeslice has 
expired or am I missing something ?

-- 
Nicolas Schichan
Freebox SAS
