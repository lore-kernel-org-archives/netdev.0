From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ / new Dummy device post.
Date: Sat, 17 Apr 2004 11:39:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40810957.6030209@dsl.pipex.com>
References: <407E5905.9070108@dsl.pipex.com>	 <1082031313.1039.13.camel@jzny.localdomain>	 <407EE3E5.8060200@dsl.pipex.com>	 <1082087553.1035.287.camel@jzny.localdomain>	 <4080356F.4020609@dsl.pipex.com> <1082145341.1026.125.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082145341.1026.125.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2004-04-16 at 15:35, Andy Furniss wrote:
> 
> 
>>This is what I wanted to know. Is it possible to make an option to get 
>>them after NAT in and pre NAT out?
> 
> 
> No i dont plan to. Why do you want to go that path?

I think it's the only way I can shape/share my ingress traffic between a 
  process (eg. bittorrent/squid) running on my shaping machine and 
traffic that is forwarded to my LAN. I masquerade onto one real dynamic IP.

In the case of pre nat outbound - I know people can mark pre NAT and 
shape on that, but it would allow people with big LANs doing NAT to use 
WRR/ESFQ on src for egress traffic.

> 
> 
>>I don't think this applies to my setup Masqerading many local onto one 
>>real address.
> 
> 
> If you have local on eth0(or substitute with whatever device you have
> local on), the example i gave should work fine. You just have to change
> the way you approach the setup. In case i didnt understand you, please
> post the details of your setup.

My setup is very simple - the only reason I use IMQ+NAT patch is because 
I want to use my gateway/shaping PC to run bittorrent and I want the LAN 
machines to have priority/fair share of incoming traffic. I guess my 
setup is not that common - more common are people who run squid on the 
same PC they shape/do NAT on.

ppp0 one dynamic real IP ->  gateway PC -> eth0 -> LAN 192.168.0.0/24
                                   |
                                    -> local process.

Andy.
