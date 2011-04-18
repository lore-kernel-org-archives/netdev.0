From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] ip6_pol_route panic: Do not allow VLAN on loopback
Date: Sun, 17 Apr 2011 23:27:45 -0700 (PDT)
Message-ID: <20110417.232745.179918571.davem@davemloft.net>
References: <20110414160704.32251.17281.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752706Ab1DRG2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 02:28:21 -0400
In-Reply-To: <20110414160704.32251.17281.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 14 Apr 2011 21:37:04 +0530

> I have tested two ways of fixing this panic:
> 	1. PATCH1: Do not allow vlan on lo.
> 	2. PATCH2: Do not propagate LOOPBACK to vlan devices.
> 
> Isn't it better to use PATCH1 and disallow vlan on lo?
> 
> The result of this patch is:
> 
> # modprobe 8021q
> # vconfig add lo 43
> ERROR: trying to add VLAN #43 to IF -:lo:-  error: Operation not supported
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

I applied this patch #1, and added some commentary to the commit message
to explain the ipv6 crash issue this fixes.

Thanks.
