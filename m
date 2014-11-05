From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: zero retrans_stamp if all retrans were
 acked
Date: Wed, 05 Nov 2014 17:00:44 -0500 (EST)
Message-ID: <20141105.170044.838421908925675417.davem@davemloft.net>
References: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
	<f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com>
	<CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, netdev@vger.kernel.org, ycheng@google.com,
	edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaKEWAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:00:47 -0500
In-Reply-To: <CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 4 Nov 2014 15:10:31 -0500

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
>>     v1->v2: fixed compilation issue noticed by Neal
>>
>>  net/ipv4/tcp_input.c | 60 +++++++++++++++++++++++++++-------------------------
>>  1 file changed, 31 insertions(+), 29 deletions(-)
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
> 
> Code looks fine, and it passes Yuchung's packetdrill test case for this.
> 
> Thanks for finding and fixing this, Marcelo.

Applied, thanks everyone.
