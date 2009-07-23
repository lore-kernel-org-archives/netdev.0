From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 14:32:18 +0530
Message-ID: <20090723090216.GA1761@serverengines.com>
References: <20090723082552.GA602@serverengines.com> <4A6823B5.7050608@trash.net>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:59492 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751881AbZGWJCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 05:02:14 -0400
Content-Disposition: inline
In-Reply-To: <4A6823B5.7050608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/07/09 10:47 +0200, Patrick McHardy wrote:
> Sarveshwar Bandi wrote:
> > Please review and apply patch to net-next tree. Patch implements the 
> > support for q-in-q mode.
> 
> Please describe your change more precisely. How does this interact with
> the stack and which VID is propagated to the VLAN code?
Patch has code to check if the controller is in q-in-q mode. When the packet
has two vids, only the inner vid is passed onto the stack. The stack is never
made aware of the outer vid.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
