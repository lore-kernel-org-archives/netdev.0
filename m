From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 14:04:17 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307241352340.2177-100000@l>
References: <200307241238510034.210E4F24@192.168.128.16>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bart De Schuymer <bdschuym@pandora.be>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200307241238510034.210E4F24@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 24 Jul 2003, Carlos Velasco wrote:

> On 24/07/2003 at 11:30 Bart De Schuymer wrote:
>
> However I don't see how these tools can help in this ARP problem.
> There is no need of filtering or mangling arp, the problem is an incorrect arp being sent.

	The src IP in the ARP probe is a hint. In most of the
cases it is ignored. But the receiver has the right to answer
based on it. You know, the reply is sent to the sender's hwaddr,
not to the src IP. Also, Linux always replies if the remote host asks
for IP configured on loopback interface. So, there is no problem.
If the remote system has your patch, there is also no problem.
What kind of problems do you see except the loopback IP as sender
IP? Dropped probes? Unanswered probes?

> Regards,
> Carlos Velasco

Regards

--
Julian Anastasov <ja@ssi.bg>
