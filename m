From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] bnx2x: move bnx2x to separate folder and
 divide to files
Date: Tue, 27 Jul 2010 13:16:12 -0700 (PDT)
Message-ID: <20100727.131612.42810423.davem@davemloft.net>
References: <1280257298.8566.8.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751407Ab0G0UPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 16:15:55 -0400
In-Reply-To: <1280257298.8566.8.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 27 Jul 2010 22:01:38 +0300

> Please consider applying following patch series to the net-next.
> The series creates separate folder for bxn2x files and divides
> bnx2x_main file into several logical parts:
> 	bnx2x_cmn.[ch] - common functionality for PF and upcommimg 
> 			 VF drivers
> 	bnx2x_stat.[ch] - statistics handling
> 	ethtool.c - ethtool related function and structs
> 
> After applying this series, integration of latest bnx2x patches
> from net-2.6 which include fixes for statistics handling can't
> be performed in a "automatic" way then i can suggest to re-submitting
> these two patches.

These patches generate the following warnings from GIT
when applying:

Applying: bnx2x: Create separate folder for bnx2x driver
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:49: new blank line at EOF.
+
warning: 1 line adds whitespace errors.
Applying: bnx2x: store module parameters in driver main structure
Applying: bnx2x: move global variable load_count to bnx2x.h
Applying: bnx2x: Create bnx2x_cmn.* files
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:39: new blank line at EOF.
+
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:2297: new blank line at EOF.
+
warning: 2 lines add whitespace errors.
Applying: bnx2x: Create separate file for ethtool routines
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:58: new blank line at EOF.
+
warning: 1 line adds whitespace errors.
Applying: bnx2x: Move statistics handling code to bnx2x_stats.*
Applying: bnx2x: update driver version to 1.52.53-3
Applying: bnx2x: Update MAINTAINERS according to new location

Fix them up and resubmit the series, thanks.
