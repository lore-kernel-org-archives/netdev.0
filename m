From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Fri, 20 Jul 2012 17:12:07 +0200
Message-ID: <1342797127.2626.7427.camel@edumazet-glaptop>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	 <1342337165.3265.10640.camel@edumazet-glaptop>
	 <CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	 <1342759989.2626.5472.camel@edumazet-glaptop>
	 <1342761865.2626.5572.camel@edumazet-glaptop>
	 <1342794821.2678.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46737 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab2GTPMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:12:13 -0400
Received: by bkwj10 with SMTP id j10so3482418bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 08:12:11 -0700 (PDT)
In-Reply-To: <1342794821.2678.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 15:33 +0100, Ben Hutchings wrote:

> Don't we need an _irq variant for drivers that support netpoll?
> 

netpoll is such a hack I would not bother having a 0.000001 % chance to
get a "about to be wrapped 64bit counter" on a 32bit cpu.
