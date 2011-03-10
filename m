From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Thu, 10 Mar 2011 15:28:48 -0800
Message-ID: <20110310152848.7b515511@nehalam>
References: <20110308093215.GA23842@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45609 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab1CJX2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 18:28:51 -0500
In-Reply-To: <20110308093215.GA23842@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Mar 2011 10:32:15 +0100
Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:

> CUBIC Hystart uses two heuristics to exit slow start earlier, before
> losses start to occur. Unfortunately, it tends to exit slow start far too
> early, causing poor performance since convergence to the optimal cwnd is
> then very slow. This was reported in
> http://permalink.gmane.org/gmane.linux.network/188169 and
> https://partner-bugzilla.redhat.com/show_bug.cgi?id=616985

Ignore the RHEL bug. RHEL 5 ships with TCP BIC (not CUBIC) by default.
There are many research papers which show that BIC is too aggressive,
and not fair.

-- 
