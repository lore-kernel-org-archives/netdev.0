From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/2] rocker: mark parameters and local variables
 as const
Date: Tue, 12 May 2015 23:25:47 -0700
Message-ID: <CAE4R7bD+0q9pcNGA2swPQ54JWxMsDB15p=bdkeqaiL5=niL9RQ@mail.gmail.com>
References: <1431496349-14833-1-git-send-email-simon.horman@netronome.com>
	<1431496349-14833-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:34090 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbbEMGZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:25:48 -0400
Received: by qgfi89 with SMTP id i89so16685442qgf.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:25:47 -0700 (PDT)
In-Reply-To: <1431496349-14833-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 10:52 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Mark parameters and local variables as const where possible.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 258 ++++++++++++++++++-----------------
>  1 file changed, 136 insertions(+), 122 deletions(-)
>

[cut]

> @@ -4833,7 +4847,7 @@ static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
>
>  static void rocker_carrier_init(struct rocker_port *rocker_port)

Why are some left un-const, like above?
