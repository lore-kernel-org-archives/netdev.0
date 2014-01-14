From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 0/8] qlcnic driver updates
Date: Tue, 14 Jan 2014 05:25:23 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F554A8@avmb2.qlogic.org>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
 <20140113.153255.182055320418133623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:25679 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042AbaANFZZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 00:25:25 -0500
In-Reply-To: <20140113.153255.182055320418133623.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 14, 2014 5:03 AM
> To: Shahed Shaikh
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH net-next 0/8] qlcnic driver updates
> 
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Date: Fri, 10 Jan 2014 11:48:51 -0500
> 
> > This series includes following changes:
> > o SRIOV and VLAN filtering related enhancements which includes
> >    - Do MAC learning for PF
> >    - Restrict VF from configuring any VLAN mode
> >    - Enable flooding on PF
> >    - Turn on promiscuous mode for PF
> >
> > o Bug fix in qlcnic_sriov_cleanup() introduced by commit
> >   154d0c81("qlcnic: VLAN enhancement for 84XX adapters")
> >
> > o Beaconing support for 83xx and 84xx series adapters
> >
> > o Allow 82xx adapter to perform IPv6 LRO even if destination IP address is
> not
> >   programmed.
> >
> > Please apply this series to net-next.
> 
> Series applied, but you really should make rx_mac_learn a bool just like
> drv_mac_learn and fdb_mac_learn already are.

Thanks David. We will a send patch to make rx_mac_lean a bool.

Thanks,
Shahed
