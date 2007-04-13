From: Daniel Schaffrath <danielschaffrath@mac.com>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 18:10:12 +0200
Message-ID: <C8747F59-1852-4002-83C2-93883376AF15@mac.com>
References: <461D2DEA.4010806@candelatech.com> <461D447C.4070408@candelatech.com> <20070411.134804.50594117.davem@davemloft.net> <461D4DD7.7020207@candelatech.com> <p73y7kx7iol.fsf@bingen.suse.de> <461E7377.3020708@candelatech.com> <20070412201940.7f570b6d.dada1@cosmosbay.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.186]:58772 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754073AbXDMQRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 12:17:19 -0400
In-Reply-To: <20070412201940.7f570b6d.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2007/04/12  , at 20:19, Eric Dumazet wrote:

> On Thu, 12 Apr 2007 10:59:19 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>>
>> Here is a tcpdump of the connection in the stalled state.  As you  
>> can see by
>> the 'time' output, it's running at around 100,000 packets per  
>> second.  tcpdump
>> dropped the vast majority of these.  Based on the network  
>> interface stats, I
>> believe both sides of the connection are sending acks at about the  
>> same
>> rate (about 160kpps when tcpdump is not running it seems).
>
> Warning : tcpdump can lie, telling you packets being transmited  
> several time.
Maybe you have further pointers how come that tcpdump lies about  
duplicated packets?

Thanks a lot,
Daniel




>
> And yes, tcpdump slow things down because of enabling accurate  
> timestamping of packets.
>
>>
>>
>> 10:46:46.541490 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48  
>> win 6132 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541494 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541567 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541653 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541886 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541891 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48  
>> win 6132 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541895 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>
>> 10:46:46.541988 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1  
>> win 114 <nop,nop,timestamp 85158912 84963208>

