From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 15 Apr 2004 08:15:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082031313.1039.13.camel@jzny.localdomain>
References: <407E5905.9070108@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <407E5905.9070108@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-04-15 at 05:42, Andy Furniss wrote:

> 
> The only reason I use IMQ (+ NAT patch) is that I need to shape ingress 
> (I know I can't shape it "properly" from the wrong end of the bottleneck 
> without an intelligent app, but the ingress policer does not let me 
> share local and forwarded bandwidth and is not fair per user if I just 
> throttle the whole link).
> 
> I am not sure if dummy will sort this for me, there may be some other way?

The summary is dummy can do what IMQ used to; it is however not related
to iptables/netfilter. 

> Basically all I need is something I can use HTB on where the qos ingress 
> box is on this diagram.

Yes you can attach a HTB. Look at the posted example in the previous
email and replace prio with HTB. 
Not sure i answered your questions.

Again to emphasize: I will send patches only to people interested.
People have to ask directly;
this is my way of monitoring what is being tested. At some point i will
make the latest patches available to everyone.

cheers,
jamal
 
