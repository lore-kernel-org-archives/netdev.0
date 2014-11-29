From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip netns: Identify netns for the current
 process
Date: Sat, 29 Nov 2014 11:18:51 -0800
Message-ID: <20141129111851.6945913b@urahara>
References: <1415377530-25568-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:52510 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbaK2TTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 14:19:01 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so8595178pad.27
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 11:19:01 -0800 (PST)
In-Reply-To: <1415377530-25568-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Nov 2014 18:25:30 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> As 'ip' util will share the same netns from the caller
> process then we can just look at /proc/self/.. to show
> the netns of the current process by:
> 
>     ip netns id
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Useful, applied.
