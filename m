From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Thu, 11 Sep 2008 09:59:13 -0700
Message-ID: <20080911165913.GA27725@xw6200.broadcom.net>
References: <20080911051244.GA27384@xw6200.broadcom.net>
 <20080910.224618.113269063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2933 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648AbYIKQ4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 12:56:19 -0400
In-Reply-To: <20080910.224618.113269063.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 10:46:18PM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Wed, 10 Sep 2008 22:12:45 -0700
> 
> > On 5761 and 5784 ASIC revision chips, there is a chance that send BDs
> > can be corrupted when CLKREQ is enabled.  This patch turns CLKREQ off
> > while the driver is in control of the device.
> >
> > This patch also bumps up the version to 3.95.
> >
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Are users really hitting this or was this discovered by your own
> internal testing and verification?

The bug was discovered by our own internal testing, but this bug is
severe enough to warrant submission to the net-2.6 kernel.  I'll be
sending a patch to stable as well.

These chips are relatively new so there isn't a whole lot of opportunity
for users to experience the problem yet.  As the chips are distributed,
the likelyhood that users will encounter this problem is pretty high.


