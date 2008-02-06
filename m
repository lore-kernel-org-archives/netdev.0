From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed,  6 Feb 2008 09:36:11 -0800
Message-ID: <47a9ee5e.15538c0a.7043.05ba@mx.google.com>
References: <20080206075030.GA454@one.firstfloor.org>
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:38419 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbYBFR3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 12:29:06 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1980681rvb.1
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2008 09:29:03 -0800 (PST)
In-Reply-To: <20080206075030.GA454@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I didn't think a module could have multiple module_inits. Are you
> sure that works?

Indeed.  That will fail whenever ipv6 is compiled as a module.  It's
been removed.  It snuck in from the v4 implementation, where I'm still
having trouble understanding why it's needed there.

--Glenn
