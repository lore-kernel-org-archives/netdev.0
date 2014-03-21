From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] htb: Move direct_qlen code part to
 htb_parse_opt().
Date: Fri, 21 Mar 2014 14:20:50 -0700
Message-ID: <20140321142050.48124da9@nehalam.linuxnetplumber.net>
References: <20140308221003.72fed9349831ff54a9cb83dc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:61152 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbaCUVUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:20:53 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so2888759pbb.8
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 14:20:53 -0700 (PDT)
In-Reply-To: <20140308221003.72fed9349831ff54a9cb83dc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Mar 2014 22:10:03 +0900
Hiroaki SHIMODA <shimoda.hiroaki@gmail.com> wrote:

> The direct_qlen command option is used with qdisc operation.
> It happened to be implemented in htb_parse_class_opt() which is called
> with class operation.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> When I read the commit b43f3318280a ("htb: add support for direct_qlen attribute")
> I supposed to direct_qlen option is for htb leaf qdisc. But
> TCA_HTB_DIRECT_QLEN is parsed in htb_init() and also according
> to the command help of htb, I thought direct_qlen was accidentally
> implemented in htb_parse_class_opt().
> Sorry if I miss something.
> 
>  tc/q_htb.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)

Applied
