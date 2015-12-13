From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMPv6 sockets
Date: Sat, 12 Dec 2015 17:26:10 -0800
Message-ID: <1449969970.9768.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <566C452A.5000204@opennms.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse White <jesse@opennms.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34334 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbLMB0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 20:26:21 -0500
Received: by pacwq6 with SMTP id wq6so84639659pac.1
        for <netdev@vger.kernel.org>; Sat, 12 Dec 2015 17:26:20 -0800 (PST)
In-Reply-To: <566C452A.5000204@opennms.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-12-12 at 11:02 -0500, Jesse White wrote:
> Hi all,
> 
> Support for IPPROTO_ICMP socket binds was added in commit
> c319b4d76b9e583a5d88d6bf190e079c4e43213d
> which allow for process to send ICMP_ECHO messages (and receive the
> corresponding ICMP_ECHOREPLY messages)
> without any special privileges.
> 
> There doesn't appear to be any similar functionality for
> IPPROTO_ICMPV6.
> 
> Would the net maintainers be open to including a patch that adds
> similar support for ICMPv6?

But there is IPv6 support already, this was added in linux-3.11 by
Lorenzo Colitti.
