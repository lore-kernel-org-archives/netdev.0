From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Tue, 20 May 2003 14:50:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECA86EF.2030001@ethanet.com>
References: <1053313298.3909.5.camel@rth.ninka.net>
 <20030519202756.I39498@shell.cyberus.ca> <3EC9B815.4000504@ethanet.com>
 <20030520080940.E40885@shell.cyberus.ca> <3ECA3E2C.20805@ethanet.com>
 <20030520105356.U41173@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20030520105356.U41173@shell.cyberus.ca>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi wrote:

>On Tue, 20 May 2003, Ethan Sommer wrote:
>
>  
>
>>Nope. I need to strip out all the nulls from the packet, or any posix
>>regex parser will think the string ends at the first null. (so protocols
>>which use null's will be difficult/impossible to identify)
>>    
>>
>
>Ok, i see your dilema. How does snort do it? I dont think copying the
>packet is the right way to do it. Could the null NOT be considered as
>something speacial unless explicitly stated?
>
>  
>
One thing I should have pointed out earlier, it only copies that 
memory/does regex stuff until it finds a match or the first 8 packets, 
whichever is less. So, at least based on my tests, it doesn't seem to 
slow down 100BT much from what it would be otherwise. We might run into 
trouble if we look at GB or 10GB, but until we find a problem with 
speed, I think it is probably more important to make this as simple and 
easy to maintain as possible. If we see a need to make it more 
complicated due to speed issues, _then_ we should think about trying to 
get rid of that copy.

Ethan
http://l7-filter.sf.net
