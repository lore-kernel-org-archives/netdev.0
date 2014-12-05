From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 REGRESSIONS] ss: Fix layout issues introduced by regression
Date: Fri, 5 Dec 2014 17:14:29 +0200
Message-ID: <CAMw6YJ+Fqbn77E5ppkEvG0PWe9hZXB0K1Y3EF8R7pctj1bYDhQ@mail.gmail.com>
References: <1417778169-12339-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:50756 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaLEPOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 10:14:30 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so1701779wiv.2
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 07:14:29 -0800 (PST)
In-Reply-To: <1417778169-12339-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 1:16 PM, Vadim Kochan <vadim4j@gmail.com> wrote:
> This patch fixes the following issues which was introduced
> by me in commits:
>
>     #1 (2dc854854b7f1b) ss: Fixed broken output for Netlink 'Peer Address:Port' column
>     ISSUE: Broken layout when all sockets are printed out
>
>     #2 (eef43b5052afb7) ss: Identify more netlink protocol names
>     ISSUE: PID is not printed if only numbers output was specified (-n)
>
> Also aligned the width of the local/peer ports to be more wider.
>
> I tested with a lot of option combinations (I may miss some test cases),
> but layout seems to me better even on the previous released version
> of iproute2/ss.
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  misc/ss.c | 30 ++++++++++--------------------
>  1 file changed, 10 insertions(+), 20 deletions(-)

Send v2 with updated commit message and subject.

Ragards,
