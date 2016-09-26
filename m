From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 3/5] ISDN-CAPI: Adjust 17 function calls together with
 variable assignments
Date: Mon, 26 Sep 2016 11:12:54 +0200
Message-ID: <1474881174.1846.8.camel@tiscali.nl>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
         <10355972-1c9b-1103-edf3-efde78237cdd@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud6.xs4all.net ([194.109.24.24]:53915 "EHLO
        lb1-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932426AbcIZJNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:13:00 -0400
In-Reply-To: <10355972-1c9b-1103-edf3-efde78237cdd@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-09-25 at 13:13 +0200, SF Markus Elfring wrote:
> The script "checkpatch.pl" can point out that assignments should usually
> not be performed within condition checks.
> Thus move the assignment for a variable to a separate statement
> in four functions.

Did you recycle this commit explanation? Because git diff tells me you
actually touched about eight functions.  

> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/isdn/capi/capidrv.c | 59 +++++++++++++++++++++++++++------------------
>  1 file changed, 36 insertions(+), 23 deletions(-)

So I ran checkpatch on this file, just like you did. Specifically, I
did:
    scripts/checkpatch.pl -f drivers/isdn/capi/capidrv.c | grep "assignment in if condition" | wc -l 

It tells me there are actually 18 instances of this "ERROR". Why did
you ignore one of it in this patch?


Paul Bolle
