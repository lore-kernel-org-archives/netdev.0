From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 02/11] IB/ipoib: Notify the world before doing unregister
Date: Mon, 17 Sep 2007 16:33:39 -0700
Message-ID: <adaps0glve4.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
	<adatzptkjyk.fsf@cisco.com> <18593.1190071438@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, monis@voltaire.com, monisonlists@gmail.com,
	ogerlitz@voltaire.com, jgarzik@pobox.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:59364 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755064AbXIQXdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 19:33:47 -0400
In-Reply-To: <18593.1190071438@death> (Jay Vosburgh's message of "Mon, 17 Sep 2007 16:23:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > 	Conceptually, I see your point and I'm ok with doing it either
 > way.  My only question is, would this change would make the ipoib module
 > dependent upon having the bonding module loaded (to resolve all of the
 > symbols)?

Yes, I guess so, if that function is in bonding.  Hmm, that wouldn't
be a good change.

Maybe this new notification function should be in net/core/dev.c
instead of exporting call_netdevice_notifiers()?

 - R.
