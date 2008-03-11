From: Ferenc Wagner <wferi@niif.hu>
Subject: bridge forwarding delay without STP
Date: Tue, 11 Mar 2008 17:49:01 +0100
Message-ID: <87ejah2ole.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:34942 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752721AbYCKQtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 12:49:06 -0400
Received: from wferi by tac.ki.iif.hu with local (Exim 4.63)
	(envelope-from <wferi@niif.hu>)
	id 1JZ7ev-0002Q0-Tt
	for netdev@vger.kernel.org; Tue, 11 Mar 2008 17:49:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

why does a bridge without STP enabled respect its forward delay and
not skip the learning state?  Forward delay is an STP parameter AFAIK
(and according to the brctl manual), so I can't see why a bridge not
doing STP should consider it at all.  Please enlighten me (and Cc: as
I'm not subscribed).
-- 
Thanks,
Feri.
