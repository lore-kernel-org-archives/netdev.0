From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: how ipv6 support multicast routing
Date: Thu, 7 Nov 2002 08:45:43 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211070844230.8435-100000@netcore.fi>
References: <005a01c28625$f63a6810$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zheng Jianping <zjp@iscas.ac.cn>
In-Reply-To: <005a01c28625$f63a6810$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Nov 2002, Zheng Jianping wrote:
> We are developing IPv6 multicast routing protocol --PIM-SM. To support IPv6 multicast packet forwarding, Linux kernel need to be modified.  I am coding the file 'ip6_mroute.c' which is  derived from 'ipmr.c' in ipv4.
>  
> My question is how to modify the IPv6 code in the kernl to make 'ip6_mroute.c' works, i.e how to modify the files such as 'ip6/ip6_ouput.c', 'ip6/route.c' , etc.
> 
> I try to refrence to IPv4 code but it seems that the routing mechanism of IPv6 is something different from IPv4. So I get confused.

have you looked at ip6_input.c/ip6_output.c already?  There's an 
(obsolete) ip6_mc_input function there, perhaps it might get you started.  
I recall usagi have made some minor modifications to it too, but I doubt 
it works.

(I'd like to see PIM-SM work myself too.)

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
