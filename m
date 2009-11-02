From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/3] TCPCT part 1b: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Mon, 02 Nov 2009 12:54:30 -0500
Message-ID: <4AEF1CD6.5080006@gmail.com>
References: <4AE6E529.706@gmail.com>	<4AEDDDF3.3070102@gmail.com>	<4AEEB842.1070705@gmail.com> <20091102.025150.73299764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:48795 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588AbZKBRyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 12:54:31 -0500
Received: by ewy28 with SMTP id 28so5095030ewy.18
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 09:54:35 -0800 (PST)
In-Reply-To: <20091102.025150.73299764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Yes, it is a problem.
> 
> You can allocate the bit when you add the feature.
> 
Sadly, I've been having very bad luck in my choice of code base, and
reviewing other similar code -- it seemed the common practice was to
specify the interface completely (even those bits not yet used).

I'll remove that line in the next pass.
