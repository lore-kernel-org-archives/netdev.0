From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH v2] can: add missing socket check in can/raw release
Date: Wed, 20 Apr 2011 13:03:34 -0400
Message-ID: <20110420170333.GD24930@redhat.com>
References: <4DAECA1B.5050300@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767Ab1DTRDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:03:38 -0400
Content-Disposition: inline
In-Reply-To: <4DAECA1B.5050300@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2011 at 01:57:15PM +0200, Oliver Hartkopp wrote:
 > v2: added space after 'if' according code style.
 > 
 > We can get here with a NULL socket argument passed from userspace,
 > so we need to handle it accordingly.
 > 
 > Thanks to Dave Jones pointing at this issue in net/can/bcm.c
 > 
 > Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

ACK. That was the first thing I hit this morning ;-)

	Dave

