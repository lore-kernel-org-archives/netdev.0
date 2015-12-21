From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [RFC 5/5] i40e/ethtool: support coalesce setting by queue
Date: Mon, 21 Dec 2015 16:49:09 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFD2BFC@fmsmsx115.amr.corp.intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
 <1450335081-3012-5-git-send-email-kan.liang@intel.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFD1CAC@fmsmsx115.amr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F077019C0D63@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7360 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbbLUQtK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 11:49:10 -0500
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F077019C0D63@SHSMSX103.ccr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> From: Liang, Kan
> Sent: Friday, December 18, 2015 1:06 PM
> 
> Hi sln,
> 
> Thanks for the comments. I will fix it in V2.
> 
> Could you please check if the following code can find and set/get vector
> correctly?
> 
> Get rx_usecs and tx_usecs per queue
> 
> +	if (queue > 0) {
> +		if (queue >= vsi->num_queue_pairs) {
> +			netif_info(pf, drv, netdev, "Invalid queue number\n");

Adding queue range information here like in the next chunk would be nice.

Otherwise, I think the rest of this looks reasonable.

sln
