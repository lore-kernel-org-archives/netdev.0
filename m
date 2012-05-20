From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Sun, 20 May 2012 22:18:41 +0300
Message-ID: <ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<4775d023592b876909aceb152f94aa01@visp.net.lb>
	<1337540825.3361.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, davem@davemloft.net,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1337540825.3361.0.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 2012-05-20 22:07, Eric Dumazet wrote:
>
> You could try latencytop, I am not sure if some obvious things will
> popup.
For sure i did. Nothing unusual here, max 5ms latency
Cause                                                Maximum     
Percentage
[__skb_recv_datagram]                               4.1 msec         
45.4 %
Waiting for event (select)                          3.9 msec         
54.6 %
Page fault                                          0.7 msec          
0.0 %
Waiting for a process to die                        0.3 msec          
0.0 %
Writing data to TTY                                 0.1 msec          
0.0 %

I will try also to find SMI interrupts detector (if i will find 
source), but i don't think it is an issue.



---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
