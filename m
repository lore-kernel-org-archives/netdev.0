From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Bugme-new] [Bug 11648] New: rtl8150 module does not unload
Date: Fri, 3 Oct 2008 12:49:03 +0400
Message-ID: <20081003084903.GA2207@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, akpm@osdl.org
To: bugme-daemon@bugzilla.kernel.org, vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:42451 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbYJCIqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 04:46:31 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1007144fkq.5
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2008 01:46:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, everybody is doing tasklet_kill() in ->close hook.

Mike, try tasklet_kill(&dev->tl); before unlink_all_urbs() like
pegasus driver is doing.
