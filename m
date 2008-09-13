From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/3] enic: Cisco 10G Ethernet driver
Date: Sat, 13 Sep 2008 15:38:10 -0400
Message-ID: <48CC16A2.7010208@pobox.com>
References: <Pine.LNX.4.64.0809081552080.13590@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39119 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbYIMTiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:38:14 -0400
In-Reply-To: <Pine.LNX.4.64.0809081552080.13590@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> Hi Jeff,
> 
> This patch set adds the Cisco 10G Ethernet driver to the Linux kernel. 
> Please consider for merging.
> 
> Modified according to Roland's suggestions:
> 
>     * depend on INET since we're selecting INET_LRO
>     * checkpatch.pl clean
>     * sparse -D__CHECK_ENDIAN__ clean
>     * remove LLTX support
>     * use PCI_VDEVICE
>     * use round_jiffies
>     * user rmb() instead of volatile
>     * remove uncalled funcs
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Overall nice and clean.  Can you send it to me as One Big Patch(tm), the 
preferred form for merging?


