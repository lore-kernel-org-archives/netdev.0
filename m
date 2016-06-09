From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] packet: compat support for sock_fprog
Date: Thu, 09 Jun 2016 11:52:30 +0200
Message-ID: <57593C5E.8090303@iogearbox.net>
References: <1465315594-84301-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, deller@gmx.de,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59903 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167AbcFIJwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 05:52:34 -0400
In-Reply-To: <1465315594-84301-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2016 06:06 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Socket option PACKET_FANOUT_DATA takes a struct sock_fprog as argument
> if PACKET_FANOUT has mode PACKET_FANOUT_CBPF. This structure contains
> a pointer into user memory. If userland is 32-bit and kernel is 64-bit
> the two disagree about the layout of struct sock_fprog.
>
> Add compat setsockopt support to convert a 32-bit compat_sock_fprog to
> a 64-bit sock_fprog. This is analogous to compat_sock_fprog support for
> SO_REUSEPORT added in commit 1957598840f4 ("soreuseport: add compat
> case for setsockopt SO_ATTACH_REUSEPORT_CBPF").
>
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Looks good to me, thanks Willem!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
