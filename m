From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: Use SOCK_DIAG_BY_FAMILY messages
Date: Fri, 20 Jan 2012 13:05:02 -0800
Message-ID: <20120120130502.0dfd535e@nehalam.linuxnetplumber.net>
References: <4EDE573A.6040607@parallels.com>
	<4EDE5898.5090809@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33514 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855Ab2ATVFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 16:05:05 -0500
In-Reply-To: <4EDE5898.5090809@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Dec 2011 22:02:00 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Applies to cd72dcf13c8a4948ee5706794714287eeff62c90 commit of the
> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git tree
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 

Rejected since this fails binary compatiablity with older kernels:

./misc/ss -a
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
TCPDIAG answers: Invalid argument
TCPDIAG answers: Invalid argument
