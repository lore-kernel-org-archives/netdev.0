From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/2] NET: sungem, use spin_trylock_irqsave
Date: Tue, 14 Jul 2009 23:18:42 +0200
Message-ID: <4A5CF632.7080105@gmail.com>
References: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>	<1247520220-31960-2-git-send-email-jirislaby@gmail.com> <20090714.141020.34896663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:39458 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520AbZGNVSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 17:18:47 -0400
In-Reply-To: <20090714.141020.34896663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2009 11:10 PM, David Miller wrote:
>> -	if (!spin_trylock(&gp->tx_lock)) {
>> +	if (!spin_trylock_irqsave(&gp->tx_lock)) {
> 
> (hint: type 'make' before you send patches!!!!)

Grr, I did but my bash_history shows that I built wrong subtree. My
apologies.
