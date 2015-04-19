From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: Re: [PATCH 2/2] checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()
Date: Mon, 20 Apr 2015 00:01:18 +0200
Message-ID: <553425AE.909@gmail.com>
References: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>	 <1429470246-15988-3-git-send-email-mateusz.kulikowski@gmail.com> <1429474813.2947.34.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:32799 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbDSWBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 18:01:22 -0400
In-Reply-To: <1429474813.2947.34.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On 19.04.2015 22:20, Joe Perches wrote:
(...)
>> +# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
>> +		if ($^V && $^V ge 5.10.0 &&
>> +			$line =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
> 
> Please align the $line with the $^V above it.

Thanks for review - I'll post v2 soon; 
Sorry for alignment issues - shame on me and my editor.

(I've found that PATCH 1/2 was also not aligned - will fix it as well)

Regards,
Mateusz
