From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Wed, 27 Apr 2011 09:28:21 -0700
Message-ID: <20110427162821.GA9762@mcarlson.broadcom.com>
References: <1303771370-32579-1-git-send-email-mcarlson@broadcom.com>
 <1303776118.24299.1.camel@Joe-Laptop>
 <20110426001738.GB802@mcarlson.broadcom.com>
 <1303776574.24299.3.camel@Joe-Laptop>
 <20110426013512.GA2031@mcarlson.broadcom.com>
 <1303841530.24299.37.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1483 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988Ab1D0QPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 12:15:34 -0400
In-Reply-To: <1303841530.24299.37.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 11:12:10AM -0700, Joe Perches wrote:
> Using a bitmap instead of separate u32 flags allows a consistent, simpler
> and more extensible mechanism to determine capabilities.
> 
> Convert bitmasks to enum.
> Add tg3_flag, tg3_flag_clear and tg3_flag_set.
> Convert the flag & bitmask tests.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I looked through it and didn't see any problems.  I've queued
Michael Chan's suggestion into my queue.

Acked-by: Matt Carlson <mcarlson@broadcom.com>

