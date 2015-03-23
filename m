From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH] lib utils: use a correct variable to get address length
Date: Mon, 23 Mar 2015 14:53:22 -0700
Message-ID: <55108B52.8050904@cumulusnetworks.com>
References: <1427145369-29477-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	Vadim Kochan <vadim4j@gmail.com>,
	Sven-Haegar Koch <haegar@sdinet.de>
To: Andrew Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33061 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbCWVxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:53:24 -0400
Received: by pabxg6 with SMTP id xg6so191386169pab.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 14:53:23 -0700 (PDT)
In-Reply-To: <1427145369-29477-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/15, 2:16 PM, Andrew Vagin wrote:
> dst->famaly is initialized in get_addr_1()
>
> This patch fixes errors like this:
> $ ip r a 10.31.0.0/16 dev br0
> Error: an inet prefix is expected rather than "10.31.0.0/16".
>
> Cc: Vadim Kochan <vadim4j@gmail.com>
> Fixes: f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
> Signed-off-by: Andrew Vagin <avagin@openvz.org>

I have already submitted similar patch 
https://patchwork.ozlabs.org/patch/451210/
