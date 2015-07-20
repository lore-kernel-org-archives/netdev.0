From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: fix display of raw sockets
Date: Mon, 20 Jul 2015 14:58:39 -0700
Message-ID: <20150720145839.79557d38@urahara>
References: <55A64D99.9090702@beyondsemi.com>
	<1436964642-35194-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	miham@beyondsemi.com, vadim4j@gmail.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36532 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924AbbGTV62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 17:58:28 -0400
Received: by pdjr16 with SMTP id r16so109729098pdj.3
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 14:58:28 -0700 (PDT)
In-Reply-To: <1436964642-35194-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jul 2015 05:50:42 -0700
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> After commit 8250bc9ff4e5 ("ss: Unify inet sockets output") raw sockets
> are displayed as udp because dgram_show_line() is used for both and
> thus IPPROTO_UDP is used for both so proto_name() returns "udp".
> Fix this by checking dg_proto which is set according to the caller of
> dgram_show_line().
> 
> Reported-by: Miha Marolt <miham@beyondsemi.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> note: use 0 instead of IPPROTO_RAW like Eric suggested
> 
>  misc/ss.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Applied, thanks.
