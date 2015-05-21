From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] Run tests forcely in separated netns
Date: Thu, 21 May 2015 14:46:01 -0700
Message-ID: <20150521144601.04956d96@urahara>
References: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34822 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473AbbEUVp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 17:45:58 -0400
Received: by pacwv17 with SMTP id wv17so623340pac.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 14:45:57 -0700 (PDT)
In-Reply-To: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2015 17:40:14 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Changed to run each test in separated network namespace by using
> 'unshare' tool from util-linux tools set, it allows to do not affect
> network setup on the host machine, 'unshare' tool is required by default.
> 
> Also added test which checks already fixed BUG related to adding default route.
> 
> Vadim Kochan (2):
>   tests: Run each test in network namespace
>   tests: Add test for 'ip route add default'
> 
>  testsuite/Makefile                           |  7 ++++++-
>  testsuite/tests/ip/route/add_default_route.t | 12 ++++++++++++
>  2 files changed, 18 insertions(+), 1 deletion(-)
>  create mode 100755 testsuite/tests/ip/route/add_default_route.t
> 

Applied thanks
