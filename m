From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] unix: add ioctl to open a unix socket file
 with O_PATH
Date: Thu, 02 Feb 2017 21:58:25 -0500 (EST)
Message-ID: <20170202.215825.2190640542795320839.davem@davemloft.net>
References: <1485975645-8437-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752258AbdBCC61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:58:27 -0500
In-Reply-To: <1485975645-8437-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Wed,  1 Feb 2017 11:00:45 -0800

> This ioctl opens a file to which a socket is bound and
> returns a file descriptor. The caller has to have CAP_NET_ADMIN
> in the socket network namespace.
> 
> Currently it is impossible to get a path and a mount point
> for a socket file. socket_diag reports address, device ID and inode
> number for unix sockets. An address can contain a relative path or
> a file may be moved somewhere. And these properties say nothing about
> a mount namespace and a mount point of a socket file.
> 
> With the introduced ioctl, we can get a path by reading
> /proc/self/fd/X and get mnt_id from /proc/self/fdinfo/X.
> 
> In CRIU we are going to use this ioctl to dump and restore unix socket.
> 
> Here is an example how it can be used:
 ...
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

This looks fine to me, applied, thanks.
