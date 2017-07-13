From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib
 rule
Date: Thu, 13 Jul 2017 13:46:15 -0600
Message-ID: <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
References: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: idosch@mellanox.com, jiri@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35219 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbdGMTqR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 15:46:17 -0400
Received: by mail-pg0-f65.google.com with SMTP id d193so7995528pgc.2
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 12:46:17 -0700 (PDT)
In-Reply-To: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/17 1:11 PM, David Ahern wrote:
> Since mlxsw is not doing a get on the rule to increase the ref count, it
> should not be doing a put.

upon further review, mlxsw is doing a get on the rule

Problem remains, but this is not the right fix.
