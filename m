From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Mon, 15 Oct 2007 14:41:18 -0400
Message-ID: <4713B44E.7030902@pobox.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com> <11920760502756-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60467 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934510AbXJOSlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 14:41:21 -0400
In-Reply-To: <11920760502756-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Convert bonding timers to workqueues.  This converts the various
> monitor functions to run in periodic work queues instead of timers.  This
> patch introduces the framework and convers the calls, but does not resolve
> various locking issues, and does not stand alone.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

"does not stand alone" == it is not bisectable?  That's a problem.

Anyway, we have more fun fish to fry:  after applying the IPoIB bonding 
patchset, this no longer applies...


