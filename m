From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 08 Sep 2007 10:57:39 -0700
Message-ID: <1189274259.12688.28.camel@localhost.localdomain>
References: <1551EAE59135BE47B544934E30FC4FC002AABA51@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"Mike Christie" <mchristi@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	"Tal Moyal" <talm@broadcom.com>,
	"Robert Lusinsky" <lusinsky@broadcom.com>,
	"Uri Elzur" <uri@broadcom.com>,
	"SCSI Mailing List" <linux-scsi@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4003 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbXIHRxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2007 13:53:54 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABA51@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-08 at 07:49 -0700, Michael Chan wrote:
> Christoph Hellwig wrote:
> 
> > Most of it should just go away, and the other bits shouldn't 
> > change over
> > the lifetime of the driver except for additions.  So there 
> > really isn't
> > any point in auto-generating it.
> > 
> 
> Yes, I agree with Mike Christie on this.  These values in
> question are defined in iSCSI RFC and therefore should be defined
> in a common file. 

Sure, we will remove these duplicate defines from bnx2i header file and
work of iscsi_proto.h macro definitions

