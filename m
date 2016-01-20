From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Wed, 20 Jan 2016 16:57:12 -0600
Message-ID: <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com> <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Doug Ledford'" <dledford@redhat.com>,
	<linux-rdma@vger.kernel.org>,
	"'Linux Netdev List'" <netdev@vger.kernel.org>,
	"'Jeff Kirsher'" <jeffrey.t.kirsher@intel.com>,
	<e1000-rdma@lists.sourceforge.net>
To: "'Or Gerlitz'" <gerlitz.or@gmail.com>,
	"'Faisal Latif'" <faisal.latif@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:33380 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752377AbcATW5K convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 17:57:10 -0500
In-Reply-To: <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Or Gerlitz
> Sent: Wednesday, January 20, 2016 4:25 PM
> To: Faisal Latif
> Cc: Doug Ledford; linux-rdma@vger.kernel.org; Linux Netdev List; Jeff Kirsher; e1000-rdma@lists.sourceforge.net
> Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
> 
> On Wed, Jan 20, 2016 at 9:40 PM, Faisal Latif <faisal.latif@intel.com> wrote:
> 
> > Changes since v2:
> [...]
> >                 *move netlink patch up
> 
> I also asked you why the port mapper code has to be present in each
> iwarp driver and not part of the IB core stack, and you responded
> "i40iw iwarp driver registers with port mapper and uses its services.
> Beside that it is not the scope of the patch series"  -- well, it is
> in the scope of upstream review to pose such questions, please
> address.
> 
> Or.

Hey Or, 

There is a common service/API in the IB core for iWarp port mapping.  See drivers/infinbiand/core/iwpm*.c and include/rdma/iw_portmap.h.

Steve.
