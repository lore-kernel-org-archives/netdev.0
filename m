From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/3 resend] ssb: PCI revision ID register is 8-bit wide
Date: Tue, 5 Jul 2011 15:33:49 -0400
Message-ID: <20110705193348.GC7540@tuxdriver.com>
References: <201107012235.28745.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mb@bu3sch.de, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33697 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab1GETqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:46:51 -0400
Content-Disposition: inline
In-Reply-To: <201107012235.28745.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 10:35:28PM +0400, Sergei Shtylyov wrote:
> The SSB code reads PCI revision ID register as 16-bit entity while the register
> is actually 8-bit only (the next 8 bits are the programming interface register).
> Fix the read and make the 'rev' field of 'struct ssb_boardinfo' 8-bit as well,
> to match the register size.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
