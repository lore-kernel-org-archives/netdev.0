From: Jiri Slaby <jirislaby@gmail.com>
Subject: sock_valbool_flag is required by VMware
Date: Fri, 30 Nov 2007 22:52:22 +0100
Message-ID: <47508616.4030705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:34060 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182AbXK3Vw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 16:52:27 -0500
Received: by mu-out-0910.google.com with SMTP id i10so156599mue
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2007 13:52:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this commit:
    [NET]: Move sock_valbool_flag to socket.c

    The sock_valbool_flag() helper is used in setsockopt to
    set or reset some flag on the sock. This helper is required
    in the net/socket.c only, so move it there.

    Besides, patch two places in sys_setsockopt() that repeat
    this helper functionality manually.

    Since this is not a bugfix, but a trivial cleanup, I
    prepared this patch against net-2.6.25, but it also
    applies (with a single offset) to the latest net-2.6.

breaks vmware module compilation, since it uses sock_valbool_flag(). Is this
their business (and they should use sock_set_flag/sock_reset_flag) or should
this be reverted?

thanks,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
