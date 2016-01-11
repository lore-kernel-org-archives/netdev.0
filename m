From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/7] openvswitch: NAT support.
Date: Mon, 11 Jan 2016 16:37:43 -0500 (EST)
Message-ID: <20160111.163743.1973583169300061048.davem@davemloft.net>
References: <1452277800-46541-1-git-send-email-jarno@ovn.org>
	<20160111185033.GA15660@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarno@ovn.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, dev@openvswitch.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933790AbcAKVhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 16:37:46 -0500
In-Reply-To: <20160111185033.GA15660@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 11 Jan 2016 19:50:33 +0100

> On Fri, Jan 08, 2016 at 10:29:53AM -0800, Jarno Rajahalme wrote:
>> This series adds NAT support to openvswitch kernel module.  A few
>> changes are needed to the netfilter code to facilitate this (patches
>> 1-2/8).  Patches 3-6 make the openvswitch kernel module ready for the
>> patch 7 that adds the NAT support by calling into netfilter NAT code
>> from the openvswitch conntrack action.
> 
> I received this batch just a bit later by when I already submitted my
> last netfilter batch to David.
> 
> I can integrate this into the nf-next tree once the David re-opens his
> merge window.
> 
> @David, let me know if you prefer an alternate path.

I'm fine if it goes via your tree Pablo.
