From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: ISDN-Gigaset: Release memory in gigaset_initcs() after an
 allocation failure
Date: Tue, 27 Sep 2016 07:20:26 +0200
Message-ID: <0d02085e-842c-4be9-f706-c43b38ce9095@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474924434.8546.29.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Memory was not released (as it would be expected) when one call
>> of further resource reservations failed.
> 
> This was the only thing in this series that triggered more than a,
> very uninspired, "meh" on first read.

Will it matter here if the function "kfree" will be called for the
data structure members "bcs" and "inbuf" after a later function call
failed within the implementation of "gigaset_initcs"?

Regards,
Markus
