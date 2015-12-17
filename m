From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute PATCH v2 2/2] ss: support closing inet sockets via
 SOCK_DESTROY.
Date: Thu, 17 Dec 2015 07:29:47 -0800
Message-ID: <1450366187.8474.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450358538-134898-1-git-send-email-lorenzo@google.com>
	 <1450358538-134898-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34135 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318AbbLQP3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:29:51 -0500
Received: by mail-pf0-f169.google.com with SMTP id 68so32482609pfc.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 07:29:51 -0800 (PST)
In-Reply-To: <1450358538-134898-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-17 at 22:22 +0900, Lorenzo Colitti wrote:
> This patch adds a -K / --kill option to ss that attempts to
> forcibly close matching sockets using SOCK_DESTROY.
> 
> This is implemented by adding a new "struct action" to struct
> filter. If necessary, this can be extended later on to support
> further actions on sockets.

Does not work for me :

lpaa23:~# ./ss dst lpaa24|wc -l
401
lpaa23:~# ./ss -K dst lpaa24|wc -l
1
lpaa23:~# ./ss dst lpaa24|wc -l
401
lpaa23:~# id
uid=0(root) gid=0(root)
groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),26(tape)

Kernel is latest David Miller net-next
