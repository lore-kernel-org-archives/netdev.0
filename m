From: David Miller <davem@davemloft.net>
Subject: Re: [patch 05/11] atm: fix const assignment/discard warnings in
 the ATM networking driver
Date: Wed, 30 Jul 2008 16:32:30 -0700 (PDT)
Message-ID: <20080730.163230.228138693.davem@davemloft.net>
References: <200807301937.m6UJbbHT012437@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com, chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758198AbYG3Xca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:32:30 -0400
In-Reply-To: <200807301937.m6UJbbHT012437@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:37 -0700

> Fix const assignment/discard warnings in the ATM networking driver.
> 
> The lane2_assoc_ind() function needed its arguments changing to match changes
> in the lane2_ops struct (patch 61c33e012964ce358b42d2a1e9cd309af5dab02b).
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, but please provide commit header line text when referencing
SHA commit IDs in the future, as per the commit log I actually used
for this change below:

atm: fix const assignment/discard warnings in the ATM networking driver

Fix const assignment/discard warnings in the ATM networking driver.

The lane2_assoc_ind() function needed its arguments changing to match changes
in the lane2_ops struct (patch 61c33e012964ce358b42d2a1e9cd309af5dab02b
"atm: use const where reasonable").

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
