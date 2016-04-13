From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: 64bit inode numbers
Date: Wed, 13 Apr 2016 13:55:11 -0700
Message-ID: <20160413135511.4e683440@xeon-e3>
References: <1460499749.6473.601.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34118 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbcDMUzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 16:55:00 -0400
Received: by mail-pf0-f178.google.com with SMTP id c20so38553900pfc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 13:55:00 -0700 (PDT)
In-Reply-To: <1460499749.6473.601.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2016 15:22:29 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Lets prepare for a possibility to have 64bit inode numbers for sockets,
> even if the kernel currently enforces 32bit numbers.
> 
> Presumably, if both kernel and userland are 64bit (no 32bit emulation),
> kernel could switch to 64bit inode numbers soon.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
 
Why not use ino_t rather than __u64 which is really intended for kernel/user abi.
Then make code generic on sizeof inode type.
