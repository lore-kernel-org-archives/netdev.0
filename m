From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 18:04:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241804140253.00527C89@192.168.128.16>
References: <Pine.LNX.4.44.0307241849341.2177-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Bart De Schuymer" <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0307241849341.2177-100000@l>
To: "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 18:54 Julian Anastasov wrote:

>	I now see, it is the so called "ARP Problem" in the IPVS
>context, many real servers and one director sharing same virtual
>IP:
>
>http://www.linuxvirtualserver.org/
>
>The most used feature for such setups:
>http://www.ssi.bg/~ja/#hidden

Julian,

This would be another approach, configuring the IP address on the ethernet interface (ex. eth0:2) and not advertising or replying arp with the hidden patch.
However the usual approach is configuring the destination IP address on a loopback interface that does real "hiding" as it's no more in ethernet interface.

Dispatched mode:
http://www.cisco.com/en/US/products/sw/iosswrel/ps1833/products_feature_guide09186a0080086f2b.html#2728293

As long as I know, Solaris 8 and Windows 2000 have no problems with the ARP Request, as they use the src IP address of the ethernet interface. But as I have seen in the RFC it seems that Cisco devices should reply to this ARP request without looking into the source ip address.

I will open a TAC case and see if they raise a bug.

Regards,
Carlos Velasco
