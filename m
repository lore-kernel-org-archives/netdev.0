From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] CONNECTOR: add a proc entry to list connectors
Date: Tue, 24 Jun 2008 09:57:19 +0800
Message-ID: <4860547F.5000002@cn.fujitsu.com>
References: <48604E44.5040402@cn.fujitsu.com> <20080623.184557.72075822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53646 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbYFXB67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 21:58:59 -0400
In-Reply-To: <20080623.184557.72075822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Li Zefan <lizf@cn.fujitsu.com>
> Date: Tue, 24 Jun 2008 09:30:44 +0800
> 
>> I got a problem when I wanted to check if the kernel supports process
>> event connector, and It seems there's no way to do this check.
> 
> Try to create a connector socket.
>  

Do you mean socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR); ?

But this has nothing to do with process event connector. If it's not
supported, both socket() and bind() return successfully, just I can
recv() nothing.
