From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol
 changes
Date: Fri, 16 May 2008 08:09:02 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABCF8@nt-irva-0751.brcm.ad.broadcom.com>
References: <20080516081330.GA26530@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Matthew Carlson" <mcarlson@broadcom.com>, linuxppc-dev@ozlabs.org,
	netdev <netdev@vger.kernel.org>
To: "Olaf Hering" <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1404 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765705AbYEPPJS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 11:09:18 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080516081330.GA26530@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olaf Hering wrote:

> Yes, this patch fixes nfsroot for me. Thanks.
> mii-tool is not shipped anymore, even in SLES10.
> I assume that ethtool is the replacement?
> 

Thanks.  We'll send the patch to DaveM and to stable
as well.

ethtool can provide some high level link parameters.
But in this case, I was trying to use mii-tool to
look at the PHY registers to help debug the problem.
ethtool would not provide that kind of information.

