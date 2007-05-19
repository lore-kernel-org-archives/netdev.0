From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited
 Slow-Start)
Date: Sat, 19 May 2007 10:32:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705191028250.23269@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
 <464DE584.7030008@ev-en.org> <464E00E5.5050801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Baruch Even <baruch@ev-en.org>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48412 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbXESHcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 03:32:24 -0400
In-Reply-To: <464E00E5.5050801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 May 2007, Rick Jones wrote:

> or is this more of a "once ssthresh is above this, behave in this new 
> way?"  

Not even that is very exact, since both ssthresh and cwnd have to be above 
max_ssthresh to get any new behavior...


-- 
 i.
