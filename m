From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch iproute2 v2 1/2] include: add linked list implementation
 from kernel
Date: Wed, 23 Mar 2016 12:22:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41124DBA@AcuExch.aculab.com>
References: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yishaih@mellanox.com" <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	"eugenia@mellanox.com" <eugenia@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"hadarh@mellanox.com" <hadarh@mellanox.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"brouer@redhat.com" <brouer@redhat
To: 'Jiri Pirko' <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:57100 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbcCWMWy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 08:22:54 -0400
In-Reply-To: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 22 March 2016 09:02
> Rename hlist.h to list.h while adding it to be aligned with kernel
...
>  include/hlist.h |  56 ----------------------------
>  include/list.h  | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

I'm not sure where this gets installed, but #include <list.h>
is likely to give grief and find the wrong file.

Even hlist.h seems a bit terse.

	David
