From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 12:35:29 +0200
Message-ID: <20100110103528.GA4769@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:56966 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0AJKfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 05:35:42 -0500
Received: by fxm7 with SMTP id 7so18881865fxm.29
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 02:35:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Stanse found a potential null dereference

Nobody learns from Coverity, it seems. :^)

snmp6_unregister_dev() always called with valid idev.
