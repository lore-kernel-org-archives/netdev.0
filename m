From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] net: sched: consolidate handle_ing and ing_filter
Date: Sat, 09 May 2015 14:07:16 -0700
Message-ID: <554E7704.90306@plumgrid.com>
References: <cover.1431203900.git.daniel@iogearbox.net> <1ce9def551699476aabe0d592825bf530c9a3e75.1431203900.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:32905 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbEIVHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:07:20 -0400
Received: by iepj10 with SMTP id j10so82168601iep.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 14:07:18 -0700 (PDT)
In-Reply-To: <1ce9def551699476aabe0d592825bf530c9a3e75.1431203900.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/9/15 1:51 PM, Daniel Borkmann wrote:
> Given quite some code has been removed from ing_filter(), we can just
> consolidate that function into handle_ing() and get rid of a few
> instructions at the same time.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   net/core/dev.c | 46 ++++++++++++++++------------------------------
>   1 file changed, 16 insertions(+), 30 deletions(-)

lovely diffstat :)

2nd patch is even better:
  3 files changed, 31 insertions(+), 61 deletions(-)

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
