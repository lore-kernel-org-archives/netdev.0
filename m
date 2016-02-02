From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: drop write-only stack variable
Date: Tue, 2 Feb 2016 20:53:13 +0300
Message-ID: <56B0ED09.4060906@cogentembedded.com>
References: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>
To: David Herrmann <dh.herrmann@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34344 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbcBBRxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 12:53:17 -0500
Received: by mail-lf0-f43.google.com with SMTP id j78so54090598lfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 09:53:16 -0800 (PST)
In-Reply-To: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/02/2016 08:17 PM, David Herrmann wrote:

> Remove a write-only stack variable from unix_attach_fds(). This is a
> left-over from the security fix in:
>
>      commit 712f4aad406bb1ed67f3f98d04c044191f0ff593
>      Author: willy tarreau <w@1wt.eu>
>      Date:   Sun Jan 10 07:54:56 2016 +0100
>
>          unix: properly account for FDs passed over unix sockets

    scripts/checkpatch.pl now enforces a ceratin commit citing style (not so 
verbose :-)).

> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
[...]

MBR, Sergei
