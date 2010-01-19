From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2] tcp: input header length, prediction, and timestamp
 bugs
Date: Tue, 19 Jan 2010 14:58:04 -0500
Message-ID: <4B560ECC.4020506@gmail.com>
References: <4B49C2D0.1070704@gmail.com> <4B50BFFC.8010108@gmail.com> <4B55ED46.40909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:63768 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab0AST6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 14:58:07 -0500
In-Reply-To: <4B55ED46.40909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> Therefore, I'll resubmit this patch, removing the existing len parameter.
> 
And for record, there's a jtcp_rcv_established(), and the len isn't used
there either (it uses skb->len instead).

I also discovered that the related tcp_rcv_state_process() and
tcp_rcv_synsent_state_process() never uses their len parameter.
So, I'll remove them, too.
