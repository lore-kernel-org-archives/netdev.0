From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx4: Set proper build dependancy with vxlan
Date: Tue, 1 Apr 2014 09:59:07 +0300
Message-ID: <533A63BB.8040301@mellanox.com>
References: <1396178905-3817-1-git-send-email-ogerlitz@mellanox.com> <20140331.162914.820542941540073428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:44566 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751509AbaDAHAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 03:00:48 -0400
In-Reply-To: <20140331.162914.820542941540073428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/03/2014 23:29, David Miller wrote:
> Please do this properly like the I40E_VXLAN Kconfig knob does, you 
> have to protect everything including the ndo_*() methods and support 
> code. 

Yep, I missed wrapping the ndo calls as the code that supports them, 
will fix it.

Or.
