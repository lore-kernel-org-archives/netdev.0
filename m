From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next v3 2/5] swdevice: add new api to set and del
 bridge port attributes
Date: Fri, 23 Jan 2015 11:24:43 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F918906532@HASMSX110.ger.corp.intel.com>
References: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com>
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
Received: from mga14.intel.com ([192.55.52.115]:34064 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087AbbAWLYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 06:24:50 -0500
In-Reply-To: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Some trivial comments:
+
+/**
+ *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
+ *	port attributes
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *
+ *	Notify switch device port of bridge port attributes
+ */
+int netdev_switch_port_bridge_setlink(struct net_device *dev,
+				      struct nlmsghdr *nlh, u16 flags) {

- Missing @flags after @nlh above.
- Wouldn't "Notify switch device port of setting bridge port attributes"  or "Notify switch device port of bridge port attributes set" be 
better here (also in terms of being consistent with the description of the netdev_switch_port_bridge_dellink() method later in this patch)? 


+/**
+ *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
+ *	attribute delete
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *
+ *	Notify switch device port of bridge port attribute delete
+ */
+int netdev_switch_port_bridge_dellink(struct net_device *dev,
+				      struct nlmsghdr *nlh, u16 flags) {

- Again, missing @flags after @nlh for this method also.

Rami Rosen
Intel Corporation
