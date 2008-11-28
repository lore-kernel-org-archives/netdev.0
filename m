From: David Miller <davem@davemloft.net>
Subject: Re: netlink: allow empty nested attributes
Date: Fri, 28 Nov 2008 03:05:47 -0800 (PST)
Message-ID: <20081128.030547.243314805.davem@davemloft.net>
References: <492E992F.7040703@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johannes@sipsolutions.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbYK1LFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 06:05:47 -0500
In-Reply-To: <492E992F.7040703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 27 Nov 2008 13:57:19 +0100

> commit 57b0afc97f8249f0b4f665aa285ed89a9178ba42
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Nov 27 13:40:31 2008 +0100
> 
>     netlink: allow empty nested attributes
>     
>     validate_nla() currently doesn't allow empty nested attributes. This
>     makes userspace code unnecessarily complicated when starting and ending
>     the nested attribute is done by generic upper level code and the inner
>     attributes are dumped by a module.
>     
>     Add a special case to accept empty nested attributes. When the nested
>     attribute is non empty, the same checks as before are performed.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
