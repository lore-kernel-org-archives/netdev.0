From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 05/13] igb: Add support for debugfs
Date: Wed, 12 Mar 2014 20:13:53 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264FAB6029@ORSMSX102.amr.corp.intel.com>
References: <1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZ+TtFRjeA=9WZMhONSd65HZwMizf732W7oe-HJ=E0MBvg@mail.gmail.com>
	<9BBC4E0CF881AA4299206E2E1412B6264FAB3870@ORSMSX102.amr.corp.intel.com>
 <20140312.154650.1047434627285395570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "or.gerlitz@gmail.com" <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"hayja@mail.uc.edu" <hayja@mail.uc.edu>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"yevgenyp@mellanox.com" <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33798 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751963AbaCLUON convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:14:13 -0400
In-Reply-To: <20140312.154650.1047434627285395570.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, March 12, 2014 12:47 PM
> To: Wyborny, Carolyn
> Cc: or.gerlitz@gmail.com; Kirsher, Jeffrey T; gospo@redhat.com;
> netdev@vger.kernel.org; sassmann@redhat.com; hayja@mail.uc.edu;
> amirv@mellanox.com; yevgenyp@mellanox.com
> Subject: Re: [net-next 05/13] igb: Add support for debugfs
> 
> From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> Date: Wed, 12 Mar 2014 16:35:49 +0000
> 
> > Josh and I tried very hard to not reimplement anything already
> > available in some other tool or mechanism and used the examples we
> > already have for this in our other drivers.  That being said, we'll
> > abide and follow any clear criteria provided.
> 
> I don't think what's being done here is appropriate.
> 
> ethtool can provide the extended statistics.
> 
> We already have a way to dump registers in ethtool as well.  If you want to add
> fine-grained register read support and write support, that would be a nice
> addition to ethtool.

Ok, I'll remove the register outputs.  Is there any objection to the other functionality provided?

Thanks,

Carolyn
