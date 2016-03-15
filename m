From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: closed SOCK_SEQPACKET socketpair must get
 SIGPIPE
Date: Tue, 15 Mar 2016 06:20:51 -0700
Message-ID: <1458048051.31401.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458032624-139688-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, rweikusat@mobileactivedefense.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36072 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbcCONUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 09:20:54 -0400
In-Reply-To: <1458032624-139688-1-git-send-email-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-15 at 10:03 +0100, Alexander Potapenko wrote:
> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if the
> socket is no longer connected.

I find this sentence slightly confusing ?

If MSG_NOSIGNAL is set, then SIGPIPE should not be generated.

s/with/without/ maybe ?
