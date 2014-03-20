From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [net-next PATCH 2/2] be2net: csum, tso and rss steering offload
 support for VxLAN
Date: Thu, 20 Mar 2014 16:08:54 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F7E199@avmb2.qlogic.org>
References: <1395312011-899-1-git-send-email-sathya.perla@emulex.com>
 <1395312011-899-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sathya Perla <sathya.perla@emulex.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32976 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757710AbaCTQI5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 12:08:57 -0400
In-Reply-To: <1395312011-899-3-git-send-email-sathya.perla@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Sathya Perla
> Sent: Thursday, March 20, 2014 4:10 PM
> To: netdev
> Subject: [net-next PATCH 2/2] be2net: csum, tso and rss steering offload
> support for VxLAN
> 
> This patch mainly implements the add/del_vxlan_port() methods by invoking
> the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
..
> +	if (skyhawk_chip(adapter)) {
> +		netdev->hw_enc_features = NETIF_F_SG |

NETIF_F_SG is already added for hw_enc_feature in  register_netdevice() by stack.
 
Thanks,
Shahed
