From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 15:02:22 -0700 (PDT)
Message-ID: <20090323.150222.165400092.davem@davemloft.net>
References: <20090319232541.GA19262@wavehammer.waldi.eu.org>
	<20090320.155030.164080684.davem@davemloft.net>
	<1237844879.18617.20.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: waldi@debian.org, ben@decadent.org.uk, davem@davemloft.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752079AbZCWWCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:02:39 -0400
In-Reply-To: <1237844879.18617.20.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 23 Mar 2009 14:47:59 -0700

> Yes, the patch looks good.  I just noticed one problem while reviewing.
> The following logic to let the firmware know about the host CPU's page
> size is missing and I'll need to add it back.  Otherwise it will only
> work on CPUs with 4K page size.

Ok.

> I'd also like to add the version information to the bnx2_fw_file_entry
> struct instead of embedding it in the file name.  It is more flexible
> this way as each section can have different versions and can be updated
> separately.  So it will look something like:

Fair enough.

> I'll generate an incremental patch on top of this one for review.

Thanks.
