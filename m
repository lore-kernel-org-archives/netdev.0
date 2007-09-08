From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 8 Sep 2007 07:49:45 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABA51@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070908115907.GA8478@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Mike Christie" <mchristi@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	"Tal Moyal" <talm@broadcom.com>,
	"Robert Lusinsky" <lusinsky@broadcom.com>,
	"Uri Elzur" <uri@broadcom.com>,
	"SCSI Mailing List" <linux-scsi@vger.kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>,
	"Anil Veerabhadrappa" <anilgv@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070908115907.GA8478@infradead.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:

> Most of it should just go away, and the other bits shouldn't 
> change over
> the lifetime of the driver except for additions.  So there 
> really isn't
> any point in auto-generating it.
> 

Yes, I agree with Mike Christie on this.  These values in
question are defined in iSCSI RFC and therefore should be defined
in a common file.

