From: Andrew Vasquez <andrew.vasquez@qlogic.com>
Subject: Re: [RFC] new qla3xxx NIC Driver v2.02.00k29
Date: Wed, 24 May 2006 22:13:52 -0700
Message-ID: <20060525051352.GE14839@andrew-vasquezs-powerbook-g4-15.local>
References: <0BB3E5E7462EEA4295BC02D49691DC070D3692@AVEXCH1.qlogic.org> <44750130.6080103@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ron Mercer <ron.mercer@qlogic.com>, netdev@vger.kernel.org,
	linux-driver@qlogic.com, Ying Ping Lok <ying.lok@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:61618 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S965042AbWEYFNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 01:13:54 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44750130.6080103@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006, Jeff Garzik wrote:

> >Third submission for the upstream inclusion of the qla3xxx Ethernet
> >driver. This is a complementary network driver for our ISP4XXX parts.
> >There is a concurrent effort underway to get the iSCSI driver (qla4xxx)
> >integrated upstream as well.
> >
> >The following files are included and have been posted to the link below:
> >
> >LICENSE.qla3xxx
> >qla3xxxsrc-v2.02.00k29.tgz
> >
> >ftp://ftp.qlogic.com/network/upstream/20.02.00k29/
> 
> Two points:
> 
> 1) the ftp:// URL doesn't work for me.

that should have read as:

ftp://ftp.qlogic.com/outgoing/linux/network/upstream/20.02.00k29/qla3xxxsrc-v2.02.00-k29.tgz

> 2) Why do we need another license?

I believe he is referring to this one:

ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k19/LICENSE.qla3xxx

which is QLogic's boiler-plate license for drivers which support
hardware that can potentially be programmed with an external firmware
blob.  In this case, the QLA3xxx boards currently run with the
'onboard' firmware image.  Above and beyond the standard GPL licencing
of the driver sources, the license goes further and states that any
firmware-blob will be licensed under the three-clause BSD license.

This is similar to QLogic's FC driver:

http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;h=9e15b4f9cd289f116a1448986847a6313d13bf5f;hb=a8bd60705aa17a998516837d9c1e503ad4cbd7fc;f=Documentation/scsi/LICENSE.qla2xxx

--
av
