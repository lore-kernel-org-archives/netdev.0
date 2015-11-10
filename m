From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Fix removal of GRE expectation entries
 created by PPTP
Date: Tue, 10 Nov 2015 17:39:11 +0100
Message-ID: <20151110163911.GA3161@salvia>
References: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
 <1447173390-2993-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53910 "EHLO salida-rhel7.int"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753454AbbKJQjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 11:39:18 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by salida-rhel7.int (Postfix) with ESMTP id 152BF1373CD
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:39:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B3A511CFD64
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:39:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1EA4011E488
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:39:12 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1447173390-2993-2-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 05:36:29PM +0100, Pablo Neira Ayuso wrote:
> From: Anthony Lineham <anthony.lineham@alliedtelesis.co.nz>
> 
> The uninitialized tuple structure caused incorrect hash calculation
> and the lookup failed.

Please, ignore this.

This patch is already in the nf tree, it just slipped through in my
last git send-email.
