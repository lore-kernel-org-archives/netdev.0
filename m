From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2 tests: Fix problem with test running
Date: Fri, 5 Sep 2014 10:07:07 -0700
Message-ID: <20140905100707.16c063e2@urahara>
References: <1409935591-30145-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57441 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbaIERHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 13:07:10 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so22462863pad.18
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 10:07:10 -0700 (PDT)
In-Reply-To: <1409935591-30145-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 19:46:31 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> index 2a4e0ba..6f2ea85 100644
> --- a/testsuite/Makefile
> +++ b/testsuite/Makefile
> @@ -1,6 +1,7 @@
>  ## -- Config --
>  DEV := lo
>  PREFIX := sudo
> +RESULTS_DIR := "results"

Why the quotes?
