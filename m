From: David Dillow <dave@thedillows.org>
Subject: Re: Re: [PATCH v2 1/2] drivers: net: ethernet: 3com: fix return
 value
Date: Tue, 27 Dec 2016 13:15:02 -0800
Message-ID: <1482873302.20986.2.camel@dillow-glaptop.roam.corp.google.com>
References: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
         <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de
To: Thomas Preisner <thomas.preisner+linux@fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:56368 "EHLO voodoobox.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752216AbcL0VPV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 16:15:21 -0500
In-Reply-To: <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-12-25 at 01:30 +0100, Thomas Preisner wrote:
> Those spaces were actually left out purposely: The file in question (typhoon.c)
> is missing those spaces between the statements (if, for, while) and the
> following opening bracket pretty much always (except 2-3 times) and we figured
> that it might be better to keep the coding style consistent since this might
> aswell have been intended by the original author.

I'm not sure if we had the rule back then, or if I just missed it.
Either way, we should follow the rules for new code if we can.

I'm not sure it's worth fixing all of the instances -- usually
formatting-only changes are not worth the churn -- but I don't have a
strong opinion on the matter.
