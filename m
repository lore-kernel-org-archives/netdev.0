From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH 2/4] [NETLINK] introduce netlink_check_skb function
Date: Sat, 12 Feb 2005 22:18:59 +0100
Message-ID: <420E72C3.1050307@eurodev.net>
References: <420BF8CB.6080005@eurodev.net> <20050211032448.GD31837@postel.suug.ch> <420D243C.4090507@eurodev.net> <20050211224354.GE31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050211224354.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas,

Thomas Graf wrote:

>>They are all the same thing. They all return 16 bytes which is the size 
>>of a netlink header. If you and someone else think that those are more 
>>readable, I'm ok with it, whatever. I just stole that piece of code as 
>>is from current checkings done in xfrm and rtnetlink.
>>    
>>
>
>That's absolutely true, my point is that while reading that line
>of code it reads like while the remaining length in the socket buffer
>is still greather or equal than the total message size until the next
>message with a payload of 0, then do something. It looks confusing at
>a first glance because you're not event interested in the payload just
>now. A choice of NLMSG_ALIGN(sizeof(*nlh)) or NLMSG_LENGTH(0) clearly
>points out that you're just checking for enough room regarding the
>netlink header in order to access it safely and do the real sanity
>check against the complete message length. Engross that thought a bit
>further, NLMSG_SPACE could change at some point assuming that it is
>only used in contexts where the total message size is in question.
>
>If you think that's too much of nitpicking, then forget about it. It's
>technicaly absolutely correct at the moment.
>  
>

Looks fine you convince me. If this is finally pushed forward, let's 
replace that line. Thanks.

--
Pablo
