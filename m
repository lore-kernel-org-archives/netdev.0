From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Thu, 31 Jan 2008 17:49:57 +0100
Message-ID: <20080131164956.GG25989@bingen.suse.de>
References: <20080130938.523292915@suse.de> <200801310359.07362.ak@suse.de> <47A16CBB.3000409@candelatech.com> <200801310755.02110.ak@suse.de> <47A1FA42.4070503@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44210 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756717AbYAaQt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 11:49:58 -0500
Content-Disposition: inline
In-Reply-To: <47A1FA42.4070503@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 08:41:38AM -0800, Ben Greear wrote:
> I don't know exactly how the tcp_tw_recycle works, but it seems like it 
> could be made to only
> take affect when all local ports are used up in TIME_WAIT.  

TIME-WAIT does not actually use up local ports; it uses up remote ports
because it is done on the LISTEN socket which has always a fixed
local port. And it has no idea how many ports the other end has left.

-Andi
