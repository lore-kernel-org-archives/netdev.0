From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: sky2: tx hang on dual-port Yukon XL when rx csum disabled
Date: Mon, 28 Jan 2008 16:38:39 -0500
Message-ID: <479E4B5F.1020903@cybernetics.com>
References: <479E2247.8080109@cybernetics.com> <36D9DB17C6DE9E40B059440DB8D95F5204481E71@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:3433 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbYA1Vij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 16:38:39 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204481E71@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> make sure to disable the default Linux arp behavior for this kind of
> test on PC3 by*
> [root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
> [root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_filter
> [root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/eth1/arp_filter
>
> *see http://linux-ip.net/html/ether-arp.html
>
>   

Yeah, that bit me a few years ago, and I now have it in one of my boot
startup scripts...

But thanks anyway.
Tony

