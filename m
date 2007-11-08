From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [PKT_SCHED] CLS_U32: Use ffs() instead of C code on
	hash mask to get first set bit.
Date: Thu, 08 Nov 2007 08:45:31 -0500
Message-ID: <1194529531.5743.9.camel@localhost>
References: 20071107.012220.17723288.davem@davemloft.net  <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@o2.pl, davem@davemloft.net
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:30865 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbXKHNpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 08:45:46 -0500
Received: by wa-out-1112.google.com with SMTP id v27so203926wah
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2007 05:45:45 -0800 (PST)
In-Reply-To: <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-11 at 13:07 +0200, Radu Rendec wrote:
> Computing the rank of the first set bit in the hash mask (for using later
> in u32_hash_fold()) was done with plain C code. Using ffs() instead makes
> the code more readable and improves performance (since ffs() is better
> optimized in assembler).
> 
> Using the conditional operator on hash mask before applying ntohl() also
> saves one ntohl() call if mask is 0.
> 
> Signed-off-by: Radu Rendec <radu.rendec@ines.ro>

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal


