From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.28-03117: WARNING: at net/ipv4/tcp_input.c:2504	tcp_mark_head_lost()
Date: Thu, 1 Jan 2009 16:28:27 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901011627020.4692@wrl-59.cs.helsinki.fi>
References: <20090101124114.GA4281@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41132 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193AbZAAO2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 09:28:31 -0500
In-Reply-To: <20090101124114.GA4281@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Jan 2009, Alexander Beregalov wrote:

> WARNING: at net/ipv4/tcp_input.c:2504 tcp_mark_head_lost+0x1df/0x200()
>  Modules linked in: w83627hf hwmon_vid i2c_nforce2
>  Pid: 0, comm: swapper Not tainted 2.6.28-03117-g6a94cb7 #1
>  Call Trace:
>   [<c040f321>] ? printk+0x18/0x1f
>   [<c0128354>] warn_on_slowpath+0x54/0x80
>   [<c014bd25>] ? __lock_acquire+0x2c5/0x1000
>   [<c014b74c>] ? trace_hardirqs_on_caller+0x7c/0x160
>   [<c0399041>] ? dev_queue_xmit+0xe1/0x5d0
>   [<c014bd25>] ? __lock_acquire+0x2c5/0x1000
>   [<c014862b>] ? trace_hardirqs_off+0xb/0x10
>   [<c03bfaff>] tcp_mark_head_lost+0x1df/0x200
>   [<c03c561d>] tcp_ack+0x18dd/0x1ef0
>   [<c03c5ec9>] tcp_rcv_established+0x299/0x5b0
>   [<c03cc840>] tcp_v4_do_rcv+0x90/0x1b0

...snip... 

Can you reproduce it?

-- 
 i.
