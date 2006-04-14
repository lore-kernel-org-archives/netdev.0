From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 15:32:19 -0700 (PDT)
Message-ID: <20060414.153219.62111494.davem@davemloft.net>
References: <20060414183658.3461.4975.stgit@gitlost.site>
	<4440112D.9040509@pobox.com>
	<Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	Jeffrey.t.kirsher@intel.com, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63153
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965120AbWDNWcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:32:06 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 15:13:31 -0700 (Pacific Daylight Time)

> in the old driver we indicate a packet with truesize = 128, which has 1000 
> bytes of data in it.  normally (for everyone using only an skb) skb->len, 
> and skb->truesize are updated by skb_put();  In this case we don't have a 
> kernel support function for adding length to skb->len *and* to 
> skb->truesize when chaining on something to ->frags[]

Where does skb_put() update truesize?
