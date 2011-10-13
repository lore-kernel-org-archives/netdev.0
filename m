From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 17:38:51 +0200
Message-ID: <20111013153850.GA2031@minipsycho>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <20111010223752.GB2373@minipsycho>
 <1318518274.9266.94.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse@nicira.com, fubar@us.ibm.com
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678Ab1JMPjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 11:39:09 -0400
Content-Disposition: inline
In-Reply-To: <1318518274.9266.94.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 13, 2011 at 05:04:34PM CEST, mbizon@freebox.fr wrote:
>
>On Tue, 2011-10-11 at 00:37 +0200, Jiri Pirko wrote:
>
>> Hmm, I must look at this again tomorrow but I have strong feeling this
>> will break some some scenario including vlan-bridge-macvlan. 
>
>unless I'm mistaken, today's behaviour:
>
># vconfig add eth0 100
># brctl addbr br0
># brctl addif br0 eth0
>
>=> eth0.100 gets no more packets, br0.100 is to be used
>
>after the patch won't we get the opposite ?

Looks like it. The question is what is the correct behaviour...

>
>-- 
>Maxime
>
>
