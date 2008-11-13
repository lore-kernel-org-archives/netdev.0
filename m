From: Saikiran Madugula <hummerbliss@gmail.com>
Subject: Re: [PATCH] remove an unnecessary field in struct tcp_skb_cb
Date: Thu, 13 Nov 2008 18:10:46 +0000
Message-ID: <491C6DA6.8030200@gmail.com>
References: <1226571707.18006.23.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:2294 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbYKMSKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 13:10:55 -0500
Received: by nf-out-0910.google.com with SMTP id d3so517620nfc.21
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 10:10:54 -0800 (PST)
In-Reply-To: <1226571707.18006.23.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Petr Tesarik wrote:
> The urg_ptr field is not used anywhere and is merely confusing.
> 
grep -r "urg_ptr" on my linux tree says otherwise.
