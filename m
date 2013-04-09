From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Tue, 09 Apr 2013 12:42:57 +0200
Message-ID: <5163F0B1.7090309@onera.fr>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr> <20121213132916.GB10703@netboy.at.omicron.at> <50C9FEC4.5050804@onera.fr> <20121213181733.GA2312@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:34451 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761639Ab3DIKy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 06:54:29 -0400
In-Reply-To: <20121213181733.GA2312@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/13/2012 07:17 PM, Richard Cochran wrote:
> On Thu, Dec 13, 2012 at 05:13:56PM +0100, Paul Chavent wrote:
>>>
>>> In order for time stamps to appear, somebody has to call
>>> skb_tx_timestamp() ...
>> Yes. "Somebody" means "the hardware driver" after completing xmit.
>> That's true ?
>
> Yes, the MAC driver must call this helper function, but not many
> drivers do this yet. You didn't say which MAC driver you are using and
> whether it supports Tx SO_TIMESTAMPING or not.
>
>> Yes, it only sets some flags. I thought that those flags was
>> required by the skb_tx_timestamp() in order to make the appropriate
>> timestamping (hardware, software, etc).
>>
>> So in order to have tx timestamp that work, both calls are needed ?
>
> Yes.
>
>> Why sock_tx_timestamp is called in packet_fill_skb and
>> packet_sendmsg_spkt and not in tpacket_fill_skb ?
>> Why i can retrieve timestamps when i add this call ?
>
> Sorry, I don't know much about packet mmap. Last time I tried it, some
> years ago, it wasn't really working.
>
> Richard
>
Hi.

Would it be possible that the packet mmap maintainers give their opinion 
on this thread please ?

Regards.

Paul.
