From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ / new Dummy device post.
Date: Thu, 15 Apr 2004 20:35:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407EE3E5.8060200@dsl.pipex.com>
References: <407E5905.9070108@dsl.pipex.com> <1082031313.1039.13.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082031313.1039.13.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2004-04-15 at 05:42, Andy Furniss wrote:
> 
> 
>>The only reason I use IMQ (+ NAT patch) is that I need to shape ingress 
>>(I know I can't shape it "properly" from the wrong end of the bottleneck 
>>without an intelligent app, but the ingress policer does not let me 
>>share local and forwarded bandwidth and is not fair per user if I just 
>>throttle the whole link).
>>
>>I am not sure if dummy will sort this for me, there may be some other way?
> 
> 
> The summary is dummy can do what IMQ used to; it is however not related
> to iptables/netfilter. 
> 
> 
>>Basically all I need is something I can use HTB on where the qos ingress 
>>box is on this diagram.
> 
> 
> Yes you can attach a HTB. Look at the posted example in the previous
> email and replace prio with HTB. 
> Not sure i answered your questions.

What I want to know is what state IP packets will be in if I 
filter/shape with dummy - In my case I would need them to have been 
demasqued so I can tell the difference between local and to be forwarded 
ingress traffic.

Ie. where on the KPTD would dummy be - IMQ appears twice and by using 
the IMQ nat patch I can use the prerouting one to filter/shape the 
packets after they are denatted.

Andy.

> 
> Again to emphasize: I will send patches only to people interested.
> People have to ask directly;
> this is my way of monitoring what is being tested. At some point i will
> make the latest patches available to everyone.
> 
> cheers,
> jamal
