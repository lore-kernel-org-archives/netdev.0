From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Fri, 17 Jul 2015 16:07:02 -0700
Message-ID: <1437174422.2495.75.camel@perches.com>
References: <20150717200031.GB30336@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0080.hostedemail.com ([216.40.44.80]:46141 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750967AbbGQXHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 19:07:05 -0400
In-Reply-To: <20150717200031.GB30336@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 22:00 +0200, Sowmini Varadhan wrote:
> __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
> which triggers unaligned access messages, so rearrange vxlan_fdb
> to avoid this in the most non-intrusive way.

What arch does this?
