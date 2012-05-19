From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Sat, 19 May 2012 05:29:58 +0300
Message-ID: <8662732227da41d686b1c9a5d2cce510@visp.net.lb>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, davem@davemloft.net
To: Tom Herbert <therbert@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>
> Not expected, we've be running e1000e with BQL for a while.  A few 
> questions:
>
> 1) What kernel are you running?
> 2) What sort of traffic load are you using?
> 3) Have you tried a different interrupt mode?
>
1)Tested 3.3, 3.3.6, 3.4-rc7.
2)Easy to reproduce:

)Open 3 ssh consoles to server with problems
)First console "ping -s1472 -i0.0001 nearby.ip" (It will help to 
trigger problem quickier)
)Second console "ping -s1472 -i0.1 nearby.ip" (Easy to see when network 
stalls - ping rise to 1000-2000ms)
)Open some large text file and scroll it down. After while you will 
feel it "stalls" and just switch to second
console to check if ping risen recently.

It was occured also on loaded NAT server, after i remove shaper from 
it, that was limiting traffic to 350Mbps,
but there traffic pattern much more complicated.

3)Not yet, i run it with default parameters. I will try now.

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
