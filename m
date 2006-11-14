From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [Fwd: Re: wan/pc300 bug found]
Date: Tue, 14 Nov 2006 16:55:27 +0100
Message-ID: <m3k61ydnv4.fsf@defiant.localdomain>
References: <4559D5BF.3080605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:28571 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S933444AbWKNPz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:55:29 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4559D5BF.3080605@garzik.org> (Jeff Garzik's message of "Tue, 14 Nov 2006 09:42:07 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> writes:

> FYI...  I'm certainly willing to remove pc300, if nobody wants it.
>
> But I am unsure whether this is a case of "vendor doesn't care" or
> "users don't care", which are two very different things...

I have a driver for PC300/RSV (dual V.35 + V.24) for years. I'm told
it works with X.21 version too. If someone has a spare T1/E1 card
(non-returnable donation only) I can try to add support as well.

T1/E1 is too complicated to maintain without the actual hardware.

Perhaps we should add my driver to the tree, mark the old one as
obsolete and look for angry reports from T1/E1 users?

My driver(s) doesn't support MLPPP but that's probably easy to change
if there is any interest.
-- 
Krzysztof Halasa
