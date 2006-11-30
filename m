From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] r8169: Fix iteration variable sign
Date: Thu, 30 Nov 2006 15:14:14 +0100
Message-ID: <200611301514.14400.mb@bu3sch.de>
References: <200611292048.45152.mb@bu3sch.de> <20061129212133.GB18057@electric-eye.fr.zoreil.com> <456EBE87.1070806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, torvalds@osdl.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:63454
	"EHLO vs166246.vserver.de") by vger.kernel.org with ESMTP
	id S936422AbWK3OOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 09:14:24 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <456EBE87.1070806@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 30 November 2006 12:20, Jeff Garzik wrote:
> Francois Romieu wrote:
> > This changes the type of variable "i" in rtl8169_init_one()
> > from "unsigned int" to "int". "i" is checked for < 0 later,
> > which can never happen for "unsigned". This results in broken
> > error handling.
> >     
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> ACK but doesn't seem to apply to 2.6.19?
> 
> should this go into #upstream rather than #upstream-fixes?

Hm, I did this against latest linus' tree.

-- 
Greetings Michael.
