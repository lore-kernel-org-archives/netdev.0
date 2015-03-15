From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 2/2] Enable configuring multicast
 group join / leave at IP level.
Date: Sun, 15 Mar 2015 12:43:17 -0700
Message-ID: <20150315124317.6a01a542@urahara>
References: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
	<1425493810-2537-3-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:32917 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCOTnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:43:15 -0400
Received: by pdnc3 with SMTP id c3so37168620pdn.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:43:15 -0700 (PDT)
In-Reply-To: <1425493810-2537-3-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Mar 2015 10:30:10 -0800
Madhu Challa <challa@noironetworks.com> wrote:

> Joining multicast group on ethernet level via "ip maddr" command would
> not work if we have an Ethernet switch that does igmp snooping since
> the switch would not replicate multicast packets on ports that did not
> have IGMP reports for the multicast addresses.
> 
> Linux vxlan interfaces created via "ip link add vxlan" have the group option
> that enables then to do the required join.
> 
> By extending ip address command with option "autojoin" we can get similar
> functionality for openvswitch vxlan interfaces as well as other tunneling
> mechanisms that need to receive multicast traffic.
> 
> example:
> ip address add 224.1.1.10/24 dev eth5 autojoin
> ip address del 224.1.1.10/24 dev eth5

Applied, but please update manual pages as well.
