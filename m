From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [Patch RFC] ndisc: Fix skb allocation size for link layer options.
Date: Sat, 29 Dec 2012 17:37:45 +0100
Message-ID: <50DF1C59.1040902@gmail.com>
References: <1356702410-32293-1-git-send-email-stephan.gatzka@gmail.com> <50DF0C4A.5020401@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59661 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab2L2Qhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 11:37:50 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so5094160bkw.19
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 08:37:48 -0800 (PST)
In-Reply-To: <50DF0C4A.5020401@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Disagree.  NDISC_OPT_SPACE() takes care size of nd option header.
Agree. I misunderstood this, my fault.

Maybe it's better to write:

#define NDISC_OPT_SPACE(len) (((len)+sizeof(nd_opt_hdr)+7)&~7)

Regards,

Stephan
