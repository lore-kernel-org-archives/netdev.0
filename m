From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v3 2/2] drivers: net: ethernet: 3com: fix return value
Date: Tue, 27 Dec 2016 13:17:33 -0800
Message-ID: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
References: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
         <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
         <1482625822-19658-3-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de
To: Thomas Preisner <thomas.preisner+linux@fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:56378 "EHLO voodoobox.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753160AbcL0VSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 16:18:16 -0500
In-Reply-To: <1482625822-19658-3-git-send-email-thomas.preisner+linux@fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-12-25 at 01:30 +0100, Thomas Preisner wrote:
> In some cases the return value of a failing function is not being used
> and the function typhoon_init_one() returns another negative error
> code instead.

I'm not sure these changes are especially valuable, since we'll need to
look at the dmesg log anyways to figure out what went wrong, but again I
don't feel strongly.

Fix up the subject issues and I'm happy to ack them.
