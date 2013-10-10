From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] {xfrm, sctp} Stick to software crc32 even if
 hardware is capable of that
Date: Thu, 10 Oct 2013 09:11:16 -0400
Message-ID: <20131010131116.GA16147@hmsreliant.think-freely.org>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, steffen.klassert@secunet.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37173 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab3JJNLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 09:11:32 -0400
Content-Disposition: inline
In-Reply-To: <1381384296-1821-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 01:51:36PM +0800, Fan Du wrote:
> igb/ixgbe have hardware sctp checksum support, when this feature is enabled
> and also IPsec is armed to protect sctp traffic, ugly things happened as
> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum every thing
> up and pack the 16bits result in the checksum field). The result is fail
> establishment of sctp communication.
> 
Shouldn't this be fixed in the xfrm code then?  E.g. check the device features
for SCTP checksum offloading and and skip the checksum during xfrm output if its
available?

Or am I missing something?
Neil
