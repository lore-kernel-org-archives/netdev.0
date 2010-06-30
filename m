From: Parav Pandit <paravpandit@yahoo.com>
Subject: ip6 route output() and ip_route_output_key() by drivers
Date: Wed, 30 Jun 2010 00:24:04 -0700 (PDT)
Message-ID: <750794.80583.qm@web30108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web30108.mail.mud.yahoo.com ([209.191.69.40]:46698 "HELO
	web30108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752769Ab0F3Haq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 03:30:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Our device driver uses ip6 route output() and typecast the return value of dst_entry to rt6_info (similar to (net/ip6/icmp.c)

Driver uses (a) rt6i_dst.addr, (b) rt6i_dst.plen and (c) rt6i_gateway to get the route entry (ip/mask, gw, netdev).

Can anyone please confirm that drivers and/or netfilter kernel modules are allowed to use them? netdev drivers like : cnic.c, cxgb3, nes are using the ipv4 API (but not IPv6 API).

Also ip_route_output_key() rtable and dst_entry doesn't seem to provide route entry's subnet mask/prefix value. how drivers/netfilter kernel module can get a ip/mask gateway value while given a destination IP address as input?

I really appreciate your inputs. I hope I am asking it on the relevant mailing list.

Regards,
Parav Pandit


      
