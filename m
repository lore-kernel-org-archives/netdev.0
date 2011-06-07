From: Dave Jones <davej@redhat.com>
Subject: Re: suspect locking in net/irda/iriap.c
Date: Mon, 6 Jun 2011 20:13:21 -0400
Message-ID: <20110607001320.GA20918@redhat.com>
References: <20110421034057.GA10536@redhat.com>
 <20110606.170056.193694265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965Ab1FGANl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 20:13:41 -0400
Content-Disposition: inline
In-Reply-To: <20110606.170056.193694265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 05:00:56PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Wed, 20 Apr 2011 23:40:58 -0400
 > 
 > > My reading of that comment suggests that the two locks aren't the same,
 > > so is this just missing a lockdep annotation ?
 > 
 > Dave, I'm going to check in the following to net-2.6 to try and
 > address this.  Let me know how it works for you.
 
will check it out once I'm done bisecting a different bug, thanks.

	Dave

