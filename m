From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/1] xfrm: Fix state threshold configuration from
 userspace
Date: Wed, 30 Sep 2015 11:39:46 +0200
Message-ID: <20150930093946.GG7701@secunet.com>
References: <1443518708-4397-1-git-send-email-michael.rossberg@tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45374 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbbI3Jju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 05:39:50 -0400
Content-Disposition: inline
In-Reply-To: <1443518708-4397-1-git-send-email-michael.rossberg@tu-ilmenau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 11:25:08AM +0200, Michael Rossberg wrote:
> Allow to change the replay threshold (XFRMA_REPLAY_THRESH) and expiry
> timer (XFRMA_ETIMER_THRESH) of a state without having to set other
> attributes like replay counter and byte lifetime. Changing these other
> values while traffic flows will break the state.
> 
> Signed-off-by: Michael Rossberg <michael.rossberg@tu-ilmenau.de>

Applied to the ipsec tree, thanks Michael!
