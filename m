From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [RFC v2 net-next 00/10] Add new drivers: qed & qede
Date: Thu, 24 Sep 2015 14:46:24 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C85908720351@avmb3.qlogic.org>
References: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:10827 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751246AbbIXOq1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 10:46:27 -0400
In-Reply-To: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Yuval Mintz [mailto:Yuval.Mintz@qlogic.com]
> Sent: Thursday, September 17, 2015 5:24 PM
> To: netdev <netdev@vger.kernel.org>
> Cc: Ariel Elior <Ariel.Elior@qlogic.com>; Yuval Mintz <Yuval.Mintz@qlogic.com>
> Subject: [RFC v2 net-next 00/10] Add new drivers: qed & qede
> 
> From: Ariel Elior <Ariel.Elior@qlogic.com>
> 
> This series implements the driver set for Qlogic's new 579xx series.
> These are 10/20/25/40/50/100 Gig capable converged nics, supporting
> ethernet (obviously), iscsi, fcoe, roce and iwarp protocols.
> 
> The overall driver design includes a common module ('qed') and protocol
> specific dependent modules for ethernet ('qede'), fcoe ('qedf'),
> iscsi ('qedi') and roce ('qedr').
> The common module contains all of the common logic, e.g. initialization,
> cleanup, infrastructure for interrupt handling, link management, slowpath
> etc. as well as protocol agnostic features, and supplying an abstraction
> layer for other modules.
> The protocol specific modules can be compiled and operated independently
> of each other, with the exception of the rdma modules which are dependent
> on the ethernet module, in accordance with the kernel rdma stack design.
> 
> This series only adds the core and ethernet modules, with basic L2
> capabilities. Future series will add the rest of the modules and enhance
> the L2 functionality.
> 
> Ths patch series is constructed of the following patches:
> qed:  Add module with basic common support
> qed:  Add basic L2 interface
> qede: Add basic Network driver
> qed:  Add slowpath L2 support
> qede: Add basic network device support
> qede: Add classification configuration
> qed:  Add link support
> qede: Add support for link
> qed:  Add statistics support
> qede: Add basic ethtool support
> 
> We don't expect the series to be accepted as is. We are looking for
> upstream community feedback and guidance. Although the series is quite
> large, it is what we viewed as the minimal set of patches to constitute
> a basic L2 driver.
> 
> This project is a team effort, thanks go to Yuval Mintz, Dmitry Kravkov,
> Michal Kalderon, Tomer Tayar, Manish Chopra, Sudarsana Kalluru,
> Rajesh Borundia, Sony Chacko, Artum Zolotushko, Harish Patil, Rasesh Mody,
> Sergey Ukhterov and Elad Manela, as well as former team members,
> Eilon Greenstein and Shmulik Ravid.
> 
> Changes from previos version:
> -----------------------------
> 
> From Version 1:
>   - Removed private license file; Instead revised comments at source headers.
> 
> Thanks,
> Ariel Elior

Hi,
Just a friendly reminder that this request for comment is still out there, and well, no comments have been forthcoming.
Thanks,
Ariel
