From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wext
Date: Wed, 04 Oct 2006 13:06:13 +0200
Message-ID: <1159959973.2817.52.camel@ux156>
References: <200610021955.23112.chunkeey@web.de>
	 <1159951043.2817.36.camel@ux156>  <200610041256.07110.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47064 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161190AbWJDLGb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 07:06:31 -0400
To: chunkeey@web.de
In-Reply-To: <200610041256.07110.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 12:56 +0200, chunkeey@web.de wrote:

> no really, the problem is that "my" hardware (aka: prism54 fullmac) does all 
> the mac-management, encryption/decryption, AP-Management,... in the firmware. 
> And all "management" operation are wrapped into a simple unique 
> 4-byte "Operation ID"... That's why the WEXT "would be better" for that 
> thing...
> 
> (Or, do I mix everything up and nl80211 has "nothing" to do with devicescape's 
> networkstack d80211?)

Yes, nl80211 is not tied to d80211, it simply provides a new way of
doing configuration.

johannes
