From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ss: fix help/man TCP-STATE description for listening
Date: Thu, 24 Aug 2017 11:02:18 -0700
Message-ID: <20170824110218.48863b45@xeon-e3>
References: <1503492471-18403-1-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34428 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751615AbdHXSC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 14:02:28 -0400
Received: by mail-pg0-f49.google.com with SMTP id a7so572999pgn.1
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 11:02:28 -0700 (PDT)
In-Reply-To: <1503492471-18403-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Aug 2017 14:47:51 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> There's some misleading information in --help and ss(8) manpage about
> TCP-STATE named 'listen'.
> ss doesn't know such a state, but it knows 'listening' state.
> 
> $ ss -tua state listen
> ss: wrong state name: listen
> 
> $ ss -tua state listening
> [...]
> 
> Addresses: https://bugs.debian.org/872990
> Reported-by: Pavel Lyulchenko <p.lyulchenko@gmail.com>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Applied. Thanks
