From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/7] via-velocity performance fixes
Date: Mon, 23 Nov 2009 08:27:08 -0800
Message-ID: <20091123082708.737854f1@nehalam>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120090348.1e51e29e@nehalam>
	<20091123143922.273d13f9@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	romieu@fr.zoreil.com
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56625 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbZKWQ1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 11:27:13 -0500
In-Reply-To: <20091123143922.273d13f9@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 14:39:22 +0100
Simon Kagstrom <simon.kagstrom@netinsight.net> wrote:

> while the VIA driver does
> 
> 	ip_summed = CHECKSUM_NONE;
> 	if (hardware sees that this is an IP packet):
> 		if (hw IP checksum is OK):
> 			if (hw sees that this is a TCP/UDP packet):
> 				if (hw TCP/UDP checksum is NOT OK):
> 					return  # Returning CHECKSUM_NONE
> 				ip_summed = CHECKSUM_UNNECESSARY
> 
> i.e., it will return CHECKSUM_NONE also for non-TCP/UDP IP packets.

That is correct assuming hardware can only checksum TCP/UDP.

-- 
