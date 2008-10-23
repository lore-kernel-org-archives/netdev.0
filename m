From: Thomas Graf <tgraf@suug.ch>
Subject: Re: libnl: nfqueue: add nfqueue specific socket allocation function
Date: Thu, 23 Oct 2008 14:01:16 +0200
Message-ID: <20081023120115.GH20815@postel.suug.ch>
References: <4900643C.6000501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36014 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbYJWMA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 08:00:56 -0400
Content-Disposition: inline
In-Reply-To: <4900643C.6000501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-10-23 13:47
> commit e92539843a0c7e5116254382626cce226bf2135e
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Oct 23 13:46:16 2008 +0200
> 
>     libnl: nfqueue: add nfqueue specific socket allocation function
>     
>     nfqueue users usually send verdict messages from the receive callback.
>     When waiting for ACKs, the receive callback might be called again
>     recursively until the stack blows up.
>     
>     Add a nfqueue specific socket allocation function that automatically
>     disables ACKing for the socket.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
