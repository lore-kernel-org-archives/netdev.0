From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] ip monitor: Dont print timestamp or banner-label for
 cloned routes
Date: Sun, 28 Sep 2014 16:02:13 -0700
Message-ID: <20140928160213.0e4b939d@urahara>
References: <1409860088-3067-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42607 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbaI1XCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:02:25 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so1510370pad.31
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:02:24 -0700 (PDT)
In-Reply-To: <1409860088-3067-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Sep 2014 22:48:08 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> This is ugly fix but solves the case when timestamp
> or banner-label is printed before the cloned route will be skipped
> by iproute filter which filters out all cached routes by default.
> In such case timestamp will be printed twice:
> 
>     Timestamp: Thu Sep  4 19:46:59 2014 457933 usec
>     Timestamp: Thu Sep  4 19:47:07 2014 977970 usec
>     10.3.5.1 dev wlp3s0 lladdr XX:XX:XX:XX:XX:XX STALE
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied
