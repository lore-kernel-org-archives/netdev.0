From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Wed, 10 Nov 2004 01:40:09 +0100
Message-ID: <41916369.7020901@trash.net>
References: <418B4C7C.8000402@crocom.com.pl>	<418EA032.7050507@trash.net>	<418ECE85.9090203@trash.net>	<20041108135431.GE31969@postel.suug.ch>	<418F9AD0.1040701@trash.net>	<20041108183300.GF31969@postel.suug.ch>	<418FCD0A.4040202@trash.net> <20041109161816.425ad7d6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, spam@crocom.com.pl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041109161816.425ad7d6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Mon, 08 Nov 2004 20:46:18 +0100
>Patrick McHardy <kaber@trash.net> wrote:
>
>  
>
>>New patch attached.
>>    
>>
>
>How do these child qdiscs get destroyed at all if you just
>remove them from the lists they are on?  How will the rest
>of destroy processing find them and clean them up?
>
>  
>
The RCU-callback calls ops->destroy. The qdisc knows about it's inner
structure and destroys all classes and the inner qdiscs. dev->qdisc_list
is just a flat list containing all qdiscs of the tree for lookups.

Regards
Patrick
