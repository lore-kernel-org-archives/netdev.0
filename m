From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 8/12] net_device seq_file
Date: Wed, 17 Jan 2007 12:36:44 -0800
Message-ID: <20070117123644.756aecc1@oldman>
References: <200701171851.14734.dim@openvz.org>
	<200701171911.53312.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, alexey@sw.ru, saw@sw.ru,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41230 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932755AbXAQUiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 15:38:04 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200701171911.53312.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Jan 2007 19:11:52 +0300
Dmitry Mishin <dim@openvz.org> wrote:

> Library function to create a seq_file in proc filesystem,
> showing some information for each netdevice.
> This code is present in the kernel in about 10 instances, and
> all of them can be converted to using introduced library function.
> 
> Signed-off-by: Andrey Savochkin <saw@swsoft.com>

But the implementations can use static data rather than allocation,
also the long term desire is to get rid of supporting most of these proc
interfaces.
