From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] r8169: Fix iteration variable sign
Date: Thu, 30 Nov 2006 06:20:39 -0500
Message-ID: <456EBE87.1070806@pobox.com>
References: <200611292048.45152.mb@bu3sch.de> <20061129212133.GB18057@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20440 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1759245AbWK3LUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 06:20:47 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061129212133.GB18057@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> This changes the type of variable "i" in rtl8169_init_one()
> from "unsigned int" to "int". "i" is checked for < 0 later,
> which can never happen for "unsigned". This results in broken
> error handling.
>     
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

ACK but doesn't seem to apply to 2.6.19?

should this go into #upstream rather than #upstream-fixes?


