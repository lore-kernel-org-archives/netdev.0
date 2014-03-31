From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next] qlcnic: Fix build failure due to undefined
 reference to `vxlan_get_rx_port'
Date: Mon, 31 Mar 2014 23:33:47 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F88F20@avmb2.qlogic.org>
References: <1396190545-20241-1-git-send-email-shahed.shaikh@qlogic.com>
 <20140331.162950.1977000263135313417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30574 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751024AbaCaXdt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:33:49 -0400
In-Reply-To: <20140331.162950.1977000263135313417.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, April 01, 2014 2:00 AM
> To: Shahed Shaikh
> Cc: netdev; Dept-HSG Linux NIC Dev
> Subject: Re: [PATCH net-next] qlcnic: Fix build failure due to undefined
> reference to `vxlan_get_rx_port'
> 
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Date: Sun, 30 Mar 2014 10:42:25 -0400
> 
> > From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> >
> > Commit 2b3d7b758c687("qlcnic: Add VXLAN Rx offload support") uses
> > vxlan_get_rx_port() which caused build failure when VXLAN=m.
> >
> > This patch fixes the build failure by adding dependency on VXLAN in
> > Kconfig of qlcnic module and use vxlan_get_rx_port() accordingly.
> >
> > Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> > ---
> > Hi David,
> >
> > Please apply this patch to net-next.
> 
> Do this properly, don't just CPP protect the symbol that fails.
> 
> Look at how I40E_VXLAN is used, it protect everything from the
> ndo_*() ops to the surrounding support code.

Hi David,

Looks like net-next is closed. Please let me know if I can send the revised version of this patch as per your suggestion.

Thanks,
Shahed
