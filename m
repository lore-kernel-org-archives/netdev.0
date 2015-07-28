From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v7 4/4] ip link: proto_down config and display.
Date: Tue, 28 Jul 2015 16:44:53 -0700
Message-ID: <20150728164453.07cf0422@urahara>
References: <1436906602-2958-5-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35273 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbbG1Xoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 19:44:44 -0400
Received: by pdrg1 with SMTP id g1so78484003pdr.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:44:44 -0700 (PDT)
In-Reply-To: <1436906602-2958-5-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jul 2015 13:43:22 -0700
anuradhak@cumulusnetworks.com wrote:

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> 
> This patch adds support to set and display protodown on a switch port. The
> switch driver can handle this error state by doing a phys down on the port.
> 
> One example user space application setting this flag is a multi-chassis
> LAG application to handle split-brain situation on peer-link failure.
> 
> Example:
> root@net-next:~# ip link set eth1 protodown on
> root@net-next:~/iproute2# ip link show eth1
> 4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff protodown on
> root@net-next:~/iproute2# ip link set eth1 protodown off
> root@net-next:~/iproute2# ip link show eth1
> 4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff
> root@net-next:~/iproute2#
> 
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

Applied to net-next branch.
