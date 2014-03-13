From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] consolidate duplicate code is
 skb_checksum_setup() helpers
Date: Thu, 13 Mar 2014 15:16:58 -0400 (EDT)
Message-ID: <20140313.151658.365532834403324479.davem@davemloft.net>
References: <530F3B8F020000780011FD33@nat28.tlf.novell.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD025D6D2@AMSPEX01CL01.citrite.net>
	<531F24050200007800122CEC@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul.Durrant@citrix.com,
	edumazet@google.com
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbaCMTRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:17:00 -0400
In-Reply-To: <531F24050200007800122CEC@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 11 Mar 2014 13:56:05 +0000

> consolidate duplicate code is skb_checksum_setup() helpers
> 
> Realizing that the skb_maybe_pull_tail() calls in the IP-protocol
> specific portions of both helpers are terminal ones (i.e. no further
> pulls are expected), their maximum size to be pulled can be made match
> their minimal size needed, thus making the code identical and hence
> possible to be moved into another helper.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Ok, looks good, applied.
