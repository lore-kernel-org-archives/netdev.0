From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 23 Apr 2004 07:29:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082719745.1057.27.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: syrius.ml@no-log.org
In-Reply-To: <87oepjx65r.87n053x65r@87llknx65r.message.id>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

On Thu, 2004-04-22 at 13:43, syrius.ml@no-log.org wrote:
> Hi,
> 
> It oops when using the ingress qdisc + action mirred egress redirect
> filter on tun0. (no egress at all, no ingress on eth0)
> It doesn't oops using an ingress qdisc + a simple police+drop filter
> on tun0...

Ok, so you have narrowed it down to mirred, tun and ingress qdisc - is
that correct? Were you using openvpn to recreate this?
BTW, would this happen if you dont issue the ping -f initially in above
setup? If yes, before you send create the problem can you send a few
pings through tap device and send me output of dmesg?

I just did a simple test with a basic program and couldnt reproduce it.
I dont have the proper setup, can you do a basic test with some other
tunneling s/ware? 
The doc for tun mentions: 
http://vtun.sourceforge.net and http://perso.enst.fr/~beyssac/pipsec/
Please compile in tun and dummy into the kernel.

BTW, i think we should take this offline; send your response directly to
me. Anyone else interested in this conversation email both of us and we
will cc you.

cheers,
jamal
