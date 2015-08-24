From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] sctp: partial chunk should be drop without sending
 abort packet
Date: Mon, 24 Aug 2015 20:22:03 +0200
Message-ID: <55DB60CB.8030002@iogearbox.net>
References: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com> <20150824124713.GZ1097@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net
To: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46789 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbHXSWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 14:22:08 -0400
In-Reply-To: <20150824124713.GZ1097@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 02:47 PM, Marcelo Ricardo Leitner wrote:
> On Mon, Aug 24, 2015 at 06:08:30PM +0800, Xin Long wrote:
>> as RFC 4960, 6.10 said, *if the receiver detects a partial chunk, it MUST drop
>> the chunk*, we should not send the abort. but if we put this discard to inside
>> state machine, it will send abort.
>>
>> so we just drop the partial chunk there, never let this chunk go into the state
>> machine.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>
> This is basically reverting a chunk of Daniel's and Vlad's 26b87c788100
> ("net: sctp: fix remote memory pressure from excessive queueing") .
> Isn't it going to re-introduce the initial issue then?

Yes, seems so.
