From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] net: Initialize table in fib result
Date: Wed, 16 Sep 2015 13:09:52 -0300
Message-ID: <CAOMZO5AZe37p4f_Wk8ktDdDO+55reKPpSb+SYt9b3dniHfexMg@mail.gmail.com>
References: <1442417925-51597-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	richard.alpe@ericsson.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36098 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbbIPQJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 12:09:53 -0400
Received: by obqa2 with SMTP id a2so153367878obq.3
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 09:09:52 -0700 (PDT)
In-Reply-To: <1442417925-51597-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2015 at 12:38 PM, David Ahern <dsa@cumulusnetworks.com> wrote:

> The root cause is use of res.table uninitialized.
>
> Thanks to Nikolay for noticing the uninitialized use amongst the maze of
> gotos.
>
> Fixes: b7503e0cdb5d ("net: Add FIB table id to rtable")
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Reported-by: Richard Alpe <richard.alpe@ericsson.com>
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Thanks, David. I am able to NFS boot again:

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
