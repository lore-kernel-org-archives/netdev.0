From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/hisax: Convert use of __constant_cpu_to_le16 to
 cpu_to_le16
Date: Sun, 07 Jun 2015 19:42:27 -0700 (PDT)
Message-ID: <20150607.194227.1322778749534777731.davem@davemloft.net>
References: <20150606011400.GA10287@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbFHCm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 22:42:28 -0400
In-Reply-To: <20150606011400.GA10287@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Sat, 6 Jun 2015 06:44:00 +0530

> In big endian cases, macro cpu_to_le16 unfolds to __swab16 which
> provides special case for constants. In little endian cases,
> __constant_cpu_to_le16 and cpu_to_le16 expand directly to the
> same expression. So, replace __constant_cpu_to_le16 with
> cpu_to_le16 with the goal of getting rid of the definition of
> __constant_cpu_to_le16 completely.
> 
> The semantic patch that performs this transformation is as follows:
> 
> @@expression x;@@
> 
> - __constant_cpu_to_le16(x)
> + cpu_to_le16(x)
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied, thanks.
