From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring mindswant
 to know why its set to zero)
Date: Wed, 16 Jul 2008 17:37:07 -0500
Message-ID: <487E7813.2040708@linux-foundation.org>
References: <487E4A6B.6040103@linux-foundation.org><20080716.133048.201600858.davem@davemloft.net><487E5C89.7050005@hp.com> <20080716.140100.20638484.davem@davemloft.net> <39C363776A4E8C4A94691D2BD9D1C9A104AFDAA4@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46944 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbYGPWhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 18:37:25 -0400
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A104AFDAA4@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Templin, Fred L wrote:

> The other implied use for IP_ID is as a uniquifier for
> duplicate packet detection (DPD), e.g., to detect routing
> loops in the network. But, 16 bits doesn't give sufficient
> uniqueness for today's data rates anway, so flooding-based
> protocols like Simplified Multicast Forwarding (SMF) really
> can't use IP_ID by itself for that purpose.

Well yes that was how the issue came about.

> SEAL extends the IP_ID to 32 bits. With 32 bits, it makes
> sense to set it as monotonically-incrementing for every
> packet out since a network-based DPD mechanism could
> potentially make use of it. Also, 32 bits avoids the ID
> wraparound issue such that a segmentation and reassembly
> mechanism can be used even at high data rates.
> 
> SEAL is specified in 'draft-templin-seal', and is also
> implemented at:
> 
>   http://osprey67.com/seal

Ahh... interesting. Maybe that would help. I will have a look at that.
