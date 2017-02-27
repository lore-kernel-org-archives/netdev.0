From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Mon, 27 Feb 2017 10:52:14 -0800
Message-ID: <20170227105214.771e19cc@xeon-e3>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33647 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdB0TWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 14:22:47 -0500
Received: by mail-pg0-f48.google.com with SMTP id 25so18141271pgy.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 11:21:34 -0800 (PST)
In-Reply-To: <20170225165900.10129-1-zaboj.campula@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Feb 2017 16:59:00 +0000
Zaboj Campula <zaboj.campula@post.cz> wrote:

> dd the argument '-tree' to ip-link to show network devices dependency tree.
> 
> Example:
> 
> $ ip -tree link
> eth0
>     bond0
> eth1
>     bond0
> eth2
>     bond1
> eth3
>     bond1

Maybe use format similar to other utilities (lspci, lsusb, etc)?
