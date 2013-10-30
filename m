From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net 0/2] qlcnic: Bug fixes
Date: Wed, 30 Oct 2013 06:44:24 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46EE8FAB@avmb2.qlogic.org>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
 <20131026.000549.2135341232449385506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:2231 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab3J3Go1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 02:44:27 -0400
In-Reply-To: <20131026.000549.2135341232449385506.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, October 26, 2013 9:36 AM
> To: Shahed Shaikh
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH net 0/2] qlcnic: Bug fixes
> 
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Date: Fri, 25 Oct 2013 10:38:35 -0400
> 
> > From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> >
> > This patch series contains following fixes-
> > * Performace drop because driver was forcing adapter not to check
> >   destination IP for LRO.
> > * driver was not issuing qlcnic_fw_cmd_set_drv_version() to 83xx adapter
> >   becasue of improper handling of QLCNIC_FW_CAPABILITY_MORE_CAPS
> bit.
> >
> > Please apply to net.
> 
> Applied, what exactly does that destination IP check do?

When a destination IP is programmed, adapter will perform LRO only on TCP packets destined to the programmed IP address. 
When the adapter is programmed to skip destination IP check, adapter performs LRO on TCP packets destined to all IP addresses.

Thanks,
Shahed
