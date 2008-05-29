From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [ipv6] Odd behaviour...
Date: Thu, 29 May 2008 00:27:29 -0700
Message-ID: <20080529002729.d87fed29.akpm@linux-foundation.org>
References: <1211842711.8367.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-kernel <Linux-kernel@vger.kernel.org>,
	linux-net <Linux-net@vger.kernel.org>, netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1211842711.8367.11.camel@localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 May 2008 00:58:30 +0200 Ian Kumlien <pomac@vapor.com> wrote:

> Hi, 
> 
> I just recently acquired a new ipv6 tunnel since my two previous brokers
> has gone out of business. I now use hurricane electrics tunnel since i
> have really good ping times to it's node in Amsterdam.
> 
> Anyways, i have setup a local network tunnel and enabled forwarding.
> 
> After about 300 seconds, it all stops working. I have to disable and
> re-enable it on the firewall/router to get it working again.
> 
> tcpdump shows the router/firewall doing odd things like:
> (i renamed my host to piv6)
> 
> 00:48:14.294173 IP6 piv6 > igloo.stacken.kth.se: ICMP6, echo request,
> seq 321, length 64
> 
> 00:48:14.341288 IP6 igloo.stacken.kth.se > piv6: ICMP6, echo reply, seq
> 321, length 64
> 
> 00:48:14.341317 IP6 fe80::55e4:1b90 > igloo.stacken.kth.se: ICMP6,
> redirect, piv6 to piv6, length 160
> 
> 00:48:14.341332 IP6 igloo.stacken.kth.se > piv6: ICMP6, echo reply, seq
> 321, length 64
> ---
> 
> fe80::55e4::1b90 is the local ip of the ipv6 tunnel.
> (note: the packet never arrives at it's destination)
> 
> Any ideas of what could be going wrong?			

(cc netdev - afaik linux-net is kind of dead)

What kernel version are you running?
