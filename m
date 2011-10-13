From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 17:04:34 +0200
Message-ID: <1318518274.9266.94.camel@sakura.staff.proxad.net>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
	 <20111010223752.GB2373@minipsycho>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse@nicira.com, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bobafett.staff.proxad.net ([213.228.1.121]:34834 "EHLO
	bobafett.staff.proxad.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab1JMPNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:13:17 -0400
In-Reply-To: <20111010223752.GB2373@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-10-11 at 00:37 +0200, Jiri Pirko wrote:

> Hmm, I must look at this again tomorrow but I have strong feeling this
> will break some some scenario including vlan-bridge-macvlan. 

unless I'm mistaken, today's behaviour:

# vconfig add eth0 100
# brctl addbr br0
# brctl addif br0 eth0

=> eth0.100 gets no more packets, br0.100 is to be used

after the patch won't we get the opposite ?

-- 
Maxime
