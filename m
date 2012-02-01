From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH] Implement IP_UNICAST_IF socket option.
Date: Wed, 1 Feb 2012 12:32:54 -0700
Message-ID: <CAEU2+vpDT5ZVAXmXf5VbNTiyEKbs9KG2b6oPr=cPDHQfBjyxkQ@mail.gmail.com>
References: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
	<20120201.141232.458020616314562146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:52499 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517Ab2BATc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 14:32:56 -0500
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q11JWsKr002417
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 1 Feb 2012 12:32:55 -0700
Received: by vbjk17 with SMTP id k17so1240265vbj.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 11:32:54 -0800 (PST)
In-Reply-To: <20120201.141232.458020616314562146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2012 at 12:12 PM, David Miller <davem@davemloft.net> wrote:
> ...
> I see no value in exporting a different API than what other systems
> use, especially if you are adding this interface exactly for providing
> support for WINE applications, so please don't do this thing with
> argument sizes and ip_mreqn.

I didn't intend to export the API differently, I clearly misread the
article on MSDN.  If I revise this patch to require an interface index
is there any chance it will be considered for inclusion?

Erich Hoover
ehoover@mines.edu
