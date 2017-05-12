From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2] netvsc: fix net poll mode
Date: Fri, 12 May 2017 16:57:45 -0700
Message-ID: <20170512165745.54621240@xeon-e3>
References: <20170512225530.2233-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34227 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755746AbdELX5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 19:57:48 -0400
Received: by mail-pf0-f171.google.com with SMTP id e64so36890070pfd.1
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 16:57:48 -0700 (PDT)
In-Reply-To: <20170512225530.2233-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 May 2017 15:55:30 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> The ndo_poll_controller function needs to schedule NAPI to pick
> up arriving packets and send completions. Otherwise no data
> will ever be received.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Hold off on this. I will send v3 with a couple other RCU related fixes.
