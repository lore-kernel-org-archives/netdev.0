From: Fernando Gont <fernando@gont.com.ar>
Subject: ICMP attacks against TCP
Date: Sun, 12 Sep 2004 22:40:04 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,

I'm the author of an IETF Internet Draft that discusses the use of ICMP to 
perform a number of attacks against TCP and other similar protocols. The 
draft can be found at: 
http://www.ietf.org/internet-drafts/draft-gont-tcpm-icmp-attacks-01.txt

The draft proposes some work-arounds that eliminate or minimize the impact 
of these attacks.

For example, one of the proposed work-arounds is to check the TCP sequence 
number that is included in the payload of ICMP error messages. While this 
check has been implemented in a number of TCP/IP stack implementations 
(including Linux), it has never been officially documented.

There are some other work-arounds (for example, ignoring ICMP Source Quench 
messages) are not implemented in Linux, though.

I'd appreciate any comments on the draft. Both for those work-arounds 
implemented by Linux, and for those that aren't. Thus, I'd be able to 
address your comments in the next revision of the draft, and will also 
sum-up your feedback and post it to the relevant IETF mailing list (that of 
the TCPM WG mailing-list).
In case there's consensus that the proposed fixes are the right way to go, 
it will probably help to move the draft forward, and thus maybe the 
proposed work-arounds will be adopted by other TCP/IP stack implementations.

Thanks!

--
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
