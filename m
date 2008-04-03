From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
 tcp_mark_head_lost+0x11d/0x150()
Date: Thu, 3 Apr 2008 16:26:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
References: <1207199456.7616.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Soeren Sonnenburg <kernel@nn7.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51223 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbYDCN0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 09:26:05 -0400
In-Reply-To: <1207199456.7616.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:

> trying to download things, I am seeing this (ignore the tainted, it is
> from madwifi and although the module is loaded the device was never
> used)
> 
> Could anyone make sense of this please?

...I'm just trying to find out who and where invariants of the TCP code
are broken. These were relatively recently enabled (pre-2.6.24 just didn't 
care too much). A number of long standing issues plus bugs from my 
modifications have been fixed because of the more rigid checking :-).

> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/0x150()

> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x270()

> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()

Can you reproduce it? 

Please include netdev next time while report networking related problems.


-- 
 i.


