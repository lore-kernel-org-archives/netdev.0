From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: can't add tc multiq
Date: Tue, 10 Feb 2009 08:53:47 -0800
Message-ID: <20090210085347.27399810@extreme>
References: <498FECAE.3020805@bigtelecom.ru>
	<20090209081553.4a874433@extreme>
	<499166EE.5010802@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59047 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbZBJQxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 11:53:50 -0500
In-Reply-To: <499166EE.5010802@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Feb 2009 14:37:18 +0300
Badalian Vyacheslav <slavon@bigtelecom.ru> wrote:

> Sorry. I have 2 different e1000e and its also can't apply multiq. How
> get number of hardware queues of device?
> 

e1000e is not multiqueue either, the only intel 1G card that does
multiqueue is the 82575/82576 gigabit ethernet family which uses
the "igb" driver.
