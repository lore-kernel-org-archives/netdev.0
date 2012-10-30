From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v4 0/21] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Mon, 29 Oct 2012 20:14:31 -0400
Message-ID: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22973 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754204Ab2J3AeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 20:34:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, October 24, 2012 8:11 PM
> To: Sony Chacko
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH V3 02/21] qlcnic: create seperate file for data path
> routines
> 
> From: Sony Chacko <sony.chacko@qlogic.com>
> Date: Tue, 23 Oct 2012 18:30:53 -0400
> 
> > +static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
> > +{
> > +	return (adapter->pdev->device ==
> PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 :
> > +0; }
> 
> "bool" is either "true" or "false", so return "true" or "false" rather than "1" or
> "0"

Re-submitting the patch set after making the changes as suggested above.

The following patch set will restructure existing Qlogic 82XX adapter
driver to create a common driver for 82XX and the new CNA - Qlogic 83XX.

Patches 1 to 11 - restructures existing 82XX adapter driver.
Patches 12 to 21 - 83XX adapter features.

Please apply the updated 21 patch series to net-next.

Thanks,
Sony
