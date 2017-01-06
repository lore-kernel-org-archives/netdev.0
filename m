From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 1/2] net: ipv4: Simplify rt_fill_info
Date: Thu, 5 Jan 2017 20:35:21 -0700
Message-ID: <ce4dad67-4452-ab40-cc00-850b687b4dd2@cumulusnetworks.com>
References: <1483673566-14311-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35612 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162359AbdAFDfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 22:35:24 -0500
Received: by mail-pf0-f173.google.com with SMTP id f144so1358988pfa.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 19:35:23 -0800 (PST)
In-Reply-To: <1483673566-14311-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/17 8:32 PM, David Ahern wrote:
> rt_fill_info has only 1 caller and both of the last 2 args -- nowait
> and flags -- are hardcoded to 0. Given that remove them as input arguments
> and simplify rt_fill_info accordingly.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/route.c | 20 +++++++-------------
>  1 file changed, 7 insertions(+), 13 deletions(-)

forgot to update the header -- this is a standalone patch for net-next. sorry.
