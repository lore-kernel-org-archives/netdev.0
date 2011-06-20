From: Barry Grussling <barry@grussling.com>
Subject: [PATCH 0/1] DSA: Enable cascading for multiple 6131 chips
Date: Mon, 20 Jun 2011 13:40:32 -0700
Message-ID: <1308602433-31320-1-git-send-email-barry@grussling.com>
Cc: buytenh@wantstofly.org, Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from duster.selinc.com ([74.117.214.140]:48634 "EHLO
	duster.selinc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab1FTVMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found that the Cascade Port field of the 6131 was always set
to 0xe which results in from_cpu frames being discarded.  This
means cascading style multi chip DSA configuration didn't work
for me.  I am a little confused by this since we configure the 
DSA routing table a little further down in the function.  

It seems like we need to enable cascading by setting the 
Cascade Port field to 0xf if we are in a multi-chip scenario.

Barry Grussling (1):
  Allow cascading to work with 6131 chip

 net/dsa/mv88e6131.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

