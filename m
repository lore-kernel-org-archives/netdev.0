From: Julian Anastasov <ja@ssi.bg>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Wed, 2 Jul 2003 01:23:25 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307020113270.2328-100000@u.domain.uli>
References: <3F020610.2080109@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F020610.2080109@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 1 Jul 2003, Ben Greear wrote:

> How did you get telnet to bind to a particular local interface?  Also, what

	I tested telnet with replacing the prefsrc, as result,
'ip route get telnet_server_ip_on_eth1' returns local_ip_from_eth0
as src.	telnetd listens as usually to 0.0.0.0, incoming connection
comes (IP1->IP2), so the server always gets two different IPs...

> ping syntax did you use?  Did you have to modify either of these applications
> to get them to work?

	Nooo :) 'ping -I IP1 IP2' or if you set IP2's prefsrc to IP1
then even 'ping IP2' works

> I looked at the patch...but don't have a good enough grasp of the routing
> code to provide a useful critique.  I believe my patch _is_ smaller though ;)

	At least, we have two alternatives :) I'm still not sure
whether the "loop" feature will need some tuning in other netsource 
places.

> Thanks,
> Ben

Regards

--
Julian Anastasov <ja@ssi.bg>
