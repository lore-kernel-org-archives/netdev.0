From: Kyle McMartin <kmcmartin@redhat.com>
Subject: Re: sky2 poweroff screws up my network
Date: Wed, 19 May 2010 11:34:12 -0400
Message-ID: <20100519153412.GM3900@ihatethathostname.lab.bos.redhat.com>
References: <20100519143208.GL3900@ihatethathostname.lab.bos.redhat.com>
 <20100519081440.2883e71d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kmcmartin@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452Ab0ESPei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 11:34:38 -0400
Content-Disposition: inline
In-Reply-To: <20100519081440.2883e71d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 08:14:40AM -0700, Stephen Hemminger wrote:
> The sky2 shutdown puts the chip in Wake On Lan state; this
> does a separate link speed negotiation (100 mbit) which may be a problem
> if speed duplex is forced.
>

Hrm, I'd disabled WoL in ethtool explicitly hoping this sort of thing
could be avioded, but it doesn't seem to help. :/

I'm not sure what you mean by "if speed duplex is forced," I've left the
nic in autoneg mode.

regards, Kyle
