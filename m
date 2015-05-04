From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Fix wrong filter behaviour
Date: Mon, 4 May 2015 08:59:48 -0700
Message-ID: <20150504085948.517d2165@urahara>
References: <1430368224-25147-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36259 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbbEDP7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:59:44 -0400
Received: by pabsx10 with SMTP id sx10so164241487pab.3
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 08:59:44 -0700 (PDT)
In-Reply-To: <1430368224-25147-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Apr 2015 07:30:24 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Fixed applying family & socket type filters.
> It was not possible to select UDP & UNIX sockets together.
> 
> Now selected families are ORed.
> 
> The problem was that filters were combined by AND.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> Reported-By: Mihai Moldovan <ionic@ionic.de>
> ---
>  misc/ss.c | 91 ++++++++++++++++++++++++++++++++++-----------------------------
>  1 file changed, 49 insertions(+), 42 deletions(-)

Applied to master (for 4.1)
