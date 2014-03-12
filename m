From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 05/13] igb: Add support for debugfs
Date: Wed, 12 Mar 2014 16:35:49 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264FAB3870@ORSMSX102.amr.corp.intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJZOPZ+TtFRjeA=9WZMhONSd65HZwMizf732W7oe-HJ=E0MBvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Josh Hay <hayja@mail.uc.edu>, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"Andy Gospodarek" <gospo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53326 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbaCLQgI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:36:08 -0400
In-Reply-To: <CAJZOPZ+TtFRjeA=9WZMhONSd65HZwMizf732W7oe-HJ=E0MBvg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Or Gerlitz
> Sent: Wednesday, March 12, 2014 8:58 AM
> To: Kirsher, Jeffrey T; David Miller; Andy Gospodarek
> Cc: Wyborny, Carolyn; netdev@vger.kernel.org; sassmann@redhat.com; Josh
> Hay; Amir Vadai; Yevgeny Petrilin
> Subject: Re: [net-next 05/13] igb: Add support for debugfs
> 
> On Wed, Mar 12, 2014 at 7:53 AM, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> wrote:
> > This patch adds the necessary defines, variables, and stats updating
> > procedures to use the commands implemented in debugfs.
> 
> Guys,
> 
> Do we have a clear criteria when it makes sense to have debugfs for network
> driver and when it doesn't, for example we got this cold shower
> http://marc.info/?l=linux-netdev&m=135959539719935&w=2 when attempting
> to do so and I am not fully clear (or want to sharpen the sow) how to review a
> concrete design/need for debugs to fall into yes, it makes sense, or no, it
> doesn't b/c there are existing mechanisms that can be used or extended for that
> matter.
> 
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a
> message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

Josh and I tried very hard to not reimplement anything already available in some other tool or mechanism and used the examples we already have for this in our other drivers.  That being said, we'll abide and follow any clear criteria provided.

Thanks,

Carolyn

Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
