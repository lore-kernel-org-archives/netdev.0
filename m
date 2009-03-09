From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iproute2 and regressing "ipv6: convert tunnels to
 net_device_ops"
Date: Mon, 9 Mar 2009 15:46:09 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903091545430.2331@fbirervta.pbzchgretzou.qr>
References: <alpine.LSU.2.00.0903091400200.28029@fbirervta.pbzchgretzou.qr> <200903091414.15171.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:38875 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbZCIOqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 10:46:13 -0400
In-Reply-To: <200903091414.15171.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(Cc'ed netdev ml)

On Monday 2009-03-09 14:14, Rafael J. Wysocki wrote:

>Hi,
>
>On Monday 09 March 2009, Jan Engelhardt wrote:
>> Hi,
>> 
>> 
>> commit 1326c3d5a4b792a2b15877feb7fb691f8945d203 
>> (v2.6.28-rc6-461-g23a12b1) broke the display of local and remote 
>> addresses of an SIT tunnel in iproute2. Instead of the addresses 
>> assigned, it only displays 0.0.0.0. The version of iproute2 is 2.6.25, 
>> as shipped with openSUSE 11.1.
>> 
>> Before:
>> # ip t a sit7 mode sit remote 1.2.3.4 local 5.6.7.8
>> # ip a
>> 7: sit7@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop stat DOWN
>>     link/sit 5.6.7.8 peer 1.2.3.4
>> 
>> After:
>> 7: sit7@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop stat DOWN
>>     link/sit 0.0.0.0 brd 0.0.0.0
>> 
>> ---->
>> commit 23a12b14715e2dcd34dc8002927263ad3437344c
>> Author: Stephen Hemminger <shemminger@vyatta.com>
>> Date:   Thu Nov 20 20:33:56 2008 -0800
>> 
>>     ipv6: convert tunnels to net_device_ops
>>     
>>     Like IPV4, convert the tunnel virtual devices to use net_device_ops.
>>     
>>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>> 
>> :040000 040000 23483d156e517904d31dd7e2276a0ff8a25f2ecc 
>> 395574b3a80869307a5e936a02598476f7e1c49b M      net
>> <----
>
>If you want me to track this, please send a copy to a mailing list with
>archives to which I can link or file a bugzilla report (with CC to me).
