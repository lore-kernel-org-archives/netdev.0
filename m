From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next v3 3/5] bridge: offload bridge port attributes
 to switch asic if feature flag set
Date: Fri, 23 Jan 2015 12:53:34 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F9189065DD@HASMSX110.ger.corp.intel.com>
References: <1421987606-10884-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2728 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbbAWMxk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 07:53:40 -0500
In-Reply-To: <1421987606-10884-4-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
There is another Linux Ethernet driver which defines the ndo_bridge_setlink() callback, which is not included in the patch. It is the 
Emulex ServerEngines' 10Gbps NIC (BladeEngine) (drivers/net/ethernet/emulex/benet).
So once the CONFIG_BE2NET kernel config item is set, running make will emit a compile warning.

Regards,
Rami Rosen
Intel Corporation
