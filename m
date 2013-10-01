From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by
 napi_disable inside local_bh_disable()d context
Date: Tue, 1 Oct 2013 12:11:34 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ADFF9EE@SJEXCHMB10.corp.ad.broadcom.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
 <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
 <20130918230943.GB11989@electric-eye.fr.zoreil.com>
 <02874ECE860811409154E81DA85FBB58565F1520@ORSMSX104.amr.corp.intel.com>
 <20130919213254.GC31672@electric-eye.fr.zoreil.com>
 <02874ECE860811409154E81DA85FBB58565F5E52@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Hyong-Youb Kim" <hykim@myri.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	"Eliezer Tamir" <eliezer.tamir@linux.intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2302 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab3JAMNr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 08:13:47 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB58565F5E52@ORSMSX104.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > I have to move the local_bh_disable in order to put napi_disable
> > outside
> > > of the call since napi_disable could sleep, causing a scheduling while
> > > atomic BUG.
> >
> > I am in violent agreement with this part.
> > --
> > Ueimor
> 
> Regards,
> Jake
> --

It seem like we've hit the same issue with the bnx2x driver.
Is there anything new about the RFC?

Thanks,
Yuval
