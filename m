From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v6 1/1] xen-netback: Handle backend state
 transitions in a more robust way
Date: Mon, 30 Sep 2013 15:14:25 -0400 (EDT)
Message-ID: <20130930.151425.434087184713961553.davem@davemloft.net>
References: <1380193792-9751-1-git-send-email-paul.durrant@citrix.com>
	<1380193792-9751-2-git-send-email-paul.durrant@citrix.com>
	<1380200853.29483.83.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, wei.liu2@citrix.com,
	david.vrabel@citrix.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab3I3TO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:14:27 -0400
In-Reply-To: <1380200853.29483.83.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 26 Sep 2013 14:07:33 +0100

> On Thu, 2013-09-26 at 12:09 +0100, Paul Durrant wrote:
>> When the frontend state changes netback now specifies its desired state to
>> a new function, set_backend_state(), which transitions through any
>> necessary intermediate states.
>> This fixes an issue observed with some old Windows frontend drivers where
>> they failed to transition through the Closing state and netback would not
>> behave correctly.
>> 
>> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks.
