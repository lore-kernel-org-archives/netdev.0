From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 15:12:43 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161508520.15835@qirst.com>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com> <20090416151504.GA28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161136220.15629@qirst.com> <20090416174422.GB28978@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:41552 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503AbZDPTTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:19:51 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5D53082C270
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:29:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id P15hN5UJA11D for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 15:29:45 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A419E82C283
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:29:40 -0400 (EDT)
In-Reply-To: <20090416174422.GB28978@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Neil Horman wrote:

> I'm sorry, I misread it (confused the definiton of a bitfield with its default
> value.  As Dave noted, the default needs to be the current behavior, not your
> new behavior.  Until thats changed, I rescind my Ack

Well guess then we need the global proc setting after all. With the
current misbehavior as a default applications need to be rebuilt and
source code that is running on multiple OSes now would have to customized
to special case for Linux.

So add a global proc setting to determine the initial setting of IP_MULTICAST_ALL?

