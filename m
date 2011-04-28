From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Thu, 28 Apr 2011 14:24:55 -0700
Message-ID: <1304025895.9358.771.camel@tardy>
References: <loom.20110427T140651-957@post.gmane.org>
	 <1303906910.3166.50.camel@edumazet-laptop>
	 <loom.20110427T142551-736@post.gmane.org>
	 <loom.20110428T083015-693@post.gmane.org>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11613 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab1D1VbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 17:31:12 -0400
In-Reply-To: <loom.20110428T083015-693@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tried out something as you said.
> 
> I introduces this lines in my code,
> 
> getsockopt(s,SOL_SOCKET,SO_RCVBUF,&optval,&optlen);
> printf("The value of optlen is %d\n",optlen);
> 
> It always displays 4.

Because the length of the optval is always 4 when retrieving the
SO_RCVBUF setting.  You want to print the value of optval.

rick jones

