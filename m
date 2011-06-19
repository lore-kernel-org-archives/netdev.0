From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/5] net:  Support ethtool ops for rx of errored frames.
Date: Mon, 20 Jun 2011 00:48:00 +0200
Message-ID: <20110619224800.GA2861@electric-eye.fr.zoreil.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com> <1308430045-24816-2-git-send-email-greearb@candelatech.com> <20110618213400.GA2741@electric-eye.fr.zoreil.com> <4DFE57DA.8090404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39278 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013Ab1FSXAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:00:48 -0400
Content-Disposition: inline
In-Reply-To: <4DFE57DA.8090404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> :
> On 06/18/2011 02:34 PM, Francois Romieu wrote:
> >greearb@candelatech.com<greearb@candelatech.com>  :
> >[...]
> >>This can be useful when sniffing dodgy networks.
> >
> >Do you plan to add something similar - i.e. not per packet - for the Tx path ?
> 
> Ability to tx errored frames?  I posted a patch to enable sending
> frames with custom (ie, invalid) Ethernet FCS, but you have to
> enable it per-socket, and it will only work with AF_PACKET sockets.
> 
> Can you offer more details on what you are asking for?

Realtek's 816[89] and 810[23] have no room in their Tx descriptors to
control ethernet checksum generation. There is a global register (TxConfig)
though. Before looking at the per-socket information, the driver would need
to be instructed to disable Tx hardware ethernet checksumming globally.

-- 
Ueimor
