From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Wed, 4 Jun 2008 09:53:07 -0400
Message-ID: <20080604135307.GI16162@csclub.uwaterloo.ca>
References: <20080602165249.52a467dc@extreme> <20080603150524.GA16165@csclub.uwaterloo.ca> <20080603085707.51fdabbb@speedy> <48456B62.8050909@trash.net> <20080603214527.GG16162@csclub.uwaterloo.ca> <4845C676.5080801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:36267 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752547AbYFDNxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 09:53:08 -0400
Content-Disposition: inline
In-Reply-To: <4845C676.5080801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2008 at 12:32:22AM +0200, Patrick McHardy wrote:
> That should be easily fixed, the kernel provides all necessary
> information to make this decision in userspace.

It seems much cleaner for zebra to only ever touch routes that it
created, which would be the ones of type zebra.  Type kernel seems best
only managed by the kernel.

-- 
Len Sorensen
