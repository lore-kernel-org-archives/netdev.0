From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Fri, 09 Dec 2016 10:03:23 +0100
Message-ID: <1481274203.13252.26.camel@tiscali.nl>
References: <20161207112203.GC5507@elgon.mountain>
         <1481137583.12596.19.camel@tiscali.nl>
         <d8eb1f69-e68e-7792-00de-b14e6bac1606@imap.cc>
         <1481144894.11167.7.camel@tiscali.nl>
         <59908d9c-1716-14cb-41aa-8a9538f53412@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud2.xs4all.net ([194.109.24.21]:37859 "EHLO
        lb1-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932347AbcLIJD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 04:03:29 -0500
In-Reply-To: <59908d9c-1716-14cb-41aa-8a9538f53412@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 23:04 +0100, Tilman Schmidt wrote:
> Not sure how much evil that does beyond the WARN, but I agree it's
> worth investigating.

For the record: NULL pointer dereference in tty_unregister_ldisc() on module
unload. rmmod got killed, module refcount set -1, etc. My test box locked up
twice some random period after all that. So quite a bit of a mess, all in all.


Paul Bolle
