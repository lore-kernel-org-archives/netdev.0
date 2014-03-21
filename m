From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [net-next PATCH 2/2] be2net: csum, tso and rss steering offload
 support for VxLAN
Date: Fri, 21 Mar 2014 06:21:13 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C2A412C5C@CMEXMB1.ad.emulex.com>
References: <1395312011-899-1-git-send-email-sathya.perla@emulex.com>
 <1395312011-899-3-git-send-email-sathya.perla@emulex.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F7E199@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:13172 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaCUGVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 02:21:17 -0400
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A46F7E199@avmb2.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Shahed Shaikh [mailto:shahed.shaikh@qlogic.com]
> >
> > This patch mainly implements the add/del_vxlan_port() methods by invoking
> > the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.
> >
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ..
> > +	if (skyhawk_chip(adapter)) {
> > +		netdev->hw_enc_features = NETIF_F_SG |
> 
> NETIF_F_SG is already added for hw_enc_feature in  register_netdevice() by stack.
> 

Ha, I'll fix this up...thanks!
