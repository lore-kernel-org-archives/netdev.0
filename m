From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 3/3] mlxsw: spectrum_router: Return extack
 message on abort due to fib rules
Date: Thu, 26 Oct 2017 09:30:50 -0600
Message-ID: <3dcd4a80-d94f-19a2-3238-49d329af1b60@gmail.com>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
 <1508994485-24533-4-git-send-email-dsahern@gmail.com>
 <20171026063846.GA19803@shredder.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:48487 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932255AbdJZPat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:30:49 -0400
Received: by mail-pf0-f170.google.com with SMTP id b79so2762430pfk.5
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:30:49 -0700 (PDT)
In-Reply-To: <20171026063846.GA19803@shredder.mtl.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 12:38 AM, Ido Schimmel wrote:
> 
> Nice idea, but one problem is that the FIB notifier is atomic and thus
> when you trigger abort you end up sleeping in an atomic context:
> 
...

> 
> How about we keep the checking and error reporting inline, but do the
> actual abort in a workqueue?

yep. Will spin a v2.
