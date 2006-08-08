From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Mon, 7 Aug 2006 23:36:50 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FA21@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <20060805202603.GA9740@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:64784 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751249AbWHHGhD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 02:37:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060805202603.GA9740@thunk.org>
To: "Theodore Tso" <tytso@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Theodore Tso wrote:

> Thanks, that description was very helpful.  Would you accept a patch
> with adding a comment describing this?

I will put it on my queue to add some comments for ASF.

> 
> It appears that there is no way of disabling ASF; is that a true
> statement?
> 

Turning off ASF is just a matter of changing some bits in NVRAM
and recalculating the checksum.  If you need the tool to do this,
I'll have someone send it to you.

Note that on some of the blade servers, I believe ASF is vital
and should not be disabled.

