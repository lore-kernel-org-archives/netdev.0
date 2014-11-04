From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH v2 net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 04 Nov 2014 18:51:37 -0200
Message-ID: <54593C59.6070004@redhat.com>
References: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>	<f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com> <CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbaKDUvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 15:51:43 -0500
In-Reply-To: <CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-11-2014 18:10, Neal Cardwell wrote:
> On Tue, Nov 4, 2014 at 2:15 PM, Marcelo Ricardo Leitner
> <mleitner@redhat.com> wrote:
> ...
>> Therefore, now we clear retrans_stamp as soon as all data during the
>> loss window is fully acked.
>>
>> Reported-by: Ueki Kohei
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>> ---
>>
>> Notes:
>>      v1->v2: fixed compilation issue noticed by Neal
>>
>>   net/ipv4/tcp_input.c | 60 +++++++++++++++++++++++++++-------------------------
>>   1 file changed, 31 insertions(+), 29 deletions(-)
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
>
> Code looks fine, and it passes Yuchung's packetdrill test case for this.
>
> Thanks for finding and fixing this, Marcelo.

And thank you guys for all the assistance on it. Btw, would you send me that 
packetdrill script? I'm curious to see how such corner case could be written 
on it.

Regards,
Marcelo
