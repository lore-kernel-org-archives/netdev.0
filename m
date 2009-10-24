From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [patch next 3/4] netxen: fix bonding support
Date: Sat, 24 Oct 2009 10:29:50 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B6E4F74@AVEXMB1.qlogic.org>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-4-git-send-email-dhananjay@netxen.com>
	<m1ljj2ps80.fsf@fess.ebiederm.org>
	<7608421F3572AB4292BB2532AE89D5658B0B6E4F72@AVEXMB1.qlogic.org>,<m1skd9letu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24072 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbZJXRan convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 13:30:43 -0400
In-Reply-To: <m1skd9letu.fsf@fess.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes.  That should prevent the null pointer deference.  Will it also
> allow setting the mac address when the NIC is down?
> 
> Eric

Yes, we do save new address in netdev->dev_addr.
This is later on programmed in hardware when interface is brought up.

-Dhannajay
