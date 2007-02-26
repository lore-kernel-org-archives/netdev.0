From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: need some help on a backport of r8169
Date: Tue, 27 Feb 2007 00:48:31 +0100
Message-ID: <20070226234831.GA12830@electric-eye.fr.zoreil.com>
References: <20070226170941.GA17587@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pascal GREGIS <pgs@synerway.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54213 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161419AbXBZXuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 18:50:52 -0500
Content-Disposition: inline
In-Reply-To: <20070226170941.GA17587@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pascal GREGIS <pgs@synerway.com> :
[...]
> Could anyone take a look at my patch and tell me what is missing,

- It lacks the adequate registers init sequence for a 8168 for instance.
- Fix went in between 2.6.11 and 2.6.12.

There are 59 r8169 related patches between 2.6.12 and current. Only a few
of those break the API. I'll give it a try tomorrow evening.

-- 
Ueimor
