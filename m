From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: remove unnecessary semicolon in
 netdev_alloc_pcpu_stats()
Date: Sat, 5 Dec 2015 18:11:58 +0100
Message-ID: <20151205171158.GA7318@salvia>
References: <1449320291-7727-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaloz@openwrt.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45126 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003AbbLERMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2015 12:12:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8EC51B6B8E
	for <netdev@vger.kernel.org>; Sat,  5 Dec 2015 18:12:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 83E8EDA7E0
	for <netdev@vger.kernel.org>; Sat,  5 Dec 2015 18:12:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 90CFADA795
	for <netdev@vger.kernel.org>; Sat,  5 Dec 2015 18:12:03 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1449320291-7727-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 05, 2015 at 01:58:11PM +0100, Felix Fietkau wrote:
> This semicolon causes a build error if the function call is wrapped in
> parentheses.
> 
> Fixes: aabc92bbe3cf ("net: add __netdev_alloc_pcpu_stats() to indicate gfp flags")
> Reported-by: Imre Kaloz <kaloz@openwrt.org>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
