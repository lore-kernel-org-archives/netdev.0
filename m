From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH iproute2] bridge: add batch command support
Date: Thu, 8 Oct 2015 10:18:59 +0200
Message-ID: <CADdy8Hqit2buVfzeweYzW=_QTOqL6kcwQjBRXfdKk9iYO_1xng@mail.gmail.com>
References: <1444283603-8084-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wkok@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36431 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbbJHITA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 04:19:00 -0400
Received: by ioii196 with SMTP id i196so49632656ioi.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 01:18:59 -0700 (PDT)
In-Reply-To: <1444283603-8084-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-08 7:53 GMT+02:00 Roopa Prabhu <roopa@cumulusnetworks.com>:
> From: Wilson Kok <wkok@cumulusnetworks.com>
>
> This patch adds support to batch bridge commands.
> Follows ip batch code.

Hello Roopa,

Thanks for providing the useful batch feature to the bridge command.

The patch looks good, except a detail:

>         fprintf(stderr,
>  "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
> +"      bridge [ -force ] -batch filename\n"

in the usage display, a tab is used to indent the second form of the
bridge command. Spaces should be used instead, to align with the first
form:

   "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
   "       bridge [ -force ] -batch filename\n"
    ^^^^^^^

Except for this detail,

Acked-by: Christophe Gouault <christophe.gouault@6wind.com>
