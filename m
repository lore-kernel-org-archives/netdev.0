From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 22:06:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4132374C.8000003@trash.net>
References: <412A8FB5.4080700@trash.net>	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>	<20040828231529.051a73cc.davem@davemloft.net>	<4132303C.2060807@trash.net> <20040829125708.5aa70469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040829125708.5aa70469.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Sun, 29 Aug 2004 21:36:28 +0200
>Patrick McHardy <kaber@trash.net> wrote:
>
>>Attached. The first patch still crashed, we need to prevent new
>>fragments from getting queued after the queue is flushed until the
>>hook in unregistered.
>>    
>>
>
>While we're doing this, is your patch similar to one of the two
>original ones that Olaf Kirch posted?  I want to give him proper
>attribution, in whatever form is reasonable, that's all.
>  
>
It is based on his second patch. He didn't sign off, otherwise I just
would have kept his Signed-off-by: line.

Regards
Patrick
