From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/2][UDP]: Make full use of proto.h.udp_hash
 innovation.
Date: Sat, 22 Mar 2008 16:56:06 -0700 (PDT)
Message-ID: <20080322.165606.194970165.davem@davemloft.net>
References: <47DFAD40.1000609@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755330AbYCVXzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 19:55:53 -0400
In-Reply-To: <47DFAD40.1000609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 18 Mar 2008 14:53:36 +0300

> After this we have only udp_lib_get_port to get the port and two 
> stubs for ipv4 and ipv6. No difference in udp and udplite except
> for initialized h.udp_hash member.
> 
> I tried to find a graceful way to drop the only difference between
> udp_v4_get_port and udp_v6_get_port (i.e. the rcv_saddr comparison 
> routine), but adding one more callback on the struct proto didn't 
> appear such :( Maybe later.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
