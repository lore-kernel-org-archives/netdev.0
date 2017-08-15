From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Tue, 15 Aug 2017 09:57:33 -0700
Message-ID: <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33297 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdHOQ5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:57:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id u185so2308843pgb.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:57:34 -0700 (PDT)
In-Reply-To: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 18:30 +0200, Paweł Staszewski wrote:
> Hi
> 
> 
> Doing some tests i discovered that when traffic is send by pktgen to 
> forwarding host where nexthop for destination network on forwarding 
> router is not reachable i have 100% cpu on all cores and perf top show 
> mostly:
> 
>      77.19%  [kernel]            [k] queued_spin_lock_slowpath
>      10.20%  [kernel]            [k] acpi_processor_ffh_cstate_enter
>       1.41%  [kernel]            [k] queued_write_lock_slowpath
> 

To the rescue (for us to help)

perf record -a -g sleep 10

perf report --stdio
