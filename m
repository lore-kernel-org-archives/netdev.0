From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] 8139cp: fix eeprom read command length
Date: Tue, 20 Jun 2006 04:52:10 -0400
Message-ID: <4497B73A.4080804@pobox.com>
References: <448FAFF5.7040701@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2760 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965074AbWFTIwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 04:52:17 -0400
To: Philip Craig <philipc@snapgear.com>
In-Reply-To: <448FAFF5.7040701@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig wrote:
> The read command for the 93C46/93C56 EEPROMS should be 3 bits plus
> the address.  This doesn't appear to affect the operation of the
> read command, but similar errors for write commands do cause failures.
> 
> Signed-off-by: Philip Craig <philipc@snapgear.com>

ACK patches 1-2, but patch appears corrupted:

[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
2 patch(es) to process.

Applying '8139cp: fix eeprom read command length'

fatal: corrupt patch at line 7

