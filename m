From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_emac: Correctly detect old link speed
Date: Wed, 16 May 2007 20:44:47 +0200
Message-ID: <200705162044.47776.sr@denx.de>
References: <200705161300.08521.sr@denx.de> <20070516173002.GA22331@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:23899 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762529AbXEPSoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 14:44:03 -0400
In-Reply-To: <20070516173002.GA22331@gate.ebshome.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 16 May 2007, Eugene Surovegin wrote:
> On Wed, May 16, 2007 at 01:00:08PM +0200, Stefan Roese wrote:
> > This patch fixes a bug where the link speed change was not
> > detected correctly. This occured on a 440SPe (EMAC4) system
> > where the old link speed was 100Mbps and the new link speed
> > is 1000Mbps.
>
> Good catch, Stefan. Unfortunately, I have to NACK your patch - you
> broke non EMAC4 builds.

Yes, you're right of course.

> Correct fix is just to remove EMAC_MR1_MF_1000GPCS from the first
> if condition.

Yep.

> I'll send correct fix shortly along with other queued patches.

Thanks.

Best regards,
Stefan
