From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 12:55:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F88602B.7020603@candelatech.com>
References: <3F87430D.2040000@tpack.net>	<3F87464B.1020908@candelatech.com>	<3F874A30.6010700@tpack.net>	<3F885418.3090407@candelatech.com> <20031011120339.0da631e6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20031011120339.0da631e6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sat, 11 Oct 2003 12:03:52 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Maybe we should have a method called:  skb_get_me_an_skb_that_I_can_modify(skb);
>>
>>Then the subtle differences between sharing, cloning, etc can be handled
>>by the skb code internally...
> 
> 
> We can't create this routine, because it depends upon context.

I have read the sk_buf.h file repeatedly trying to get this all straight
in my head, and I think I'm still missing things.  Is there any other
documentation around that describes in detail exactly the things you must
do to handle shared skbs in all contexts?

I have a question on linearize as well.  Assuming I want to read the IP address
in a packet.  Do I have to linearize before I start looking at offsets in the
skb?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
