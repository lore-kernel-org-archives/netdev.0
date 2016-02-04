From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Thu, 4 Feb 2016 19:01:55 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CB6D2ED@HASMSX110.ger.corp.intel.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com>
 <20160203133356.GA2219@nanopsycho.orion> <56B219FA.7080208@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yishaih@mellanox.com" <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	"eugenia@mellanox.com" <eugenia@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"hadarh@mellanox.com" <hadarh@mellanox.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jbenc@redhat.com" <jbenc@redhat.com>,
	"Rosen, Rami" <rami.
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56131 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235AbcBDTCv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 14:02:51 -0500
In-Reply-To: <56B219FA.7080208@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>Btw, if you add this tool into iproute2 (which would be preferred), >then
>probably dl should be ok (and easier retrievable in that relation).

+1.

This tool, which uses netlink messages, seems a natural candidate for iproute2.
 
And also apart from "ip", we have also another short command in iproute2, namely "tc", which is yet another justification for using the short form with "dl".

Regards,
Rami Rosen
Intel Corporation
