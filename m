From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 02:01:46 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307240149480.1181-100000@u.domain.uli>
References: <200307231712000985.1CE20A63@192.168.128.16>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200307231712000985.1CE20A63@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 23 Jul 2003, Carlos Velasco wrote:

> When linux machine tries to find out the mac address of 192.168.128.60 with
> ARP, it uses the loopback IP address (lo:2) as source insted of the IP address
> of the ethernet interface (eth0).

	You are right but the kernel tries to preserve the sender's
IP. This helps the receiver to select the best interface
to answer this ARP probe - the same where the IP packet will be
accepted later. As there are different setups, the tuning of the
ARP handling can be done better with user tools such as arptables
and iparp.

http://sourceforge.net/projects/ebtables/
http://www.ssi.bg/~ja/#iparp

> Regards,
> Carlos Velasco

Regards

--
Julian Anastasov <ja@ssi.bg>
