From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [Gigaset307x-common] ISDN-Gigaset: Release memory in
 gigaset_initcs() after an allocation failure
Date: Tue, 27 Sep 2016 14:52:48 +0200
Message-ID: <02ad1fea-33f6-a38a-fd91-16bc0c351bdd@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
 <0d02085e-842c-4be9-f706-c43b38ce9095@users.sourceforge.net>
 <1474966121.9970.5.camel@tiscali.nl>
 <ad12e1a0-f5d5-176a-7d37-be2f3cb0af5d@users.sourceforge.net>
 <1474971962.1601897.738261385.73EB49E0@webmail.messagingengine.com>
 <5974a2c5-2739-cd69-6e37-04a645bc08d7@users.sourceforge.net>
 <baa46a3d-1f73-2f7e-6402-98763b159739@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, Paul Bolle <pebolle@tiscali.nl>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:50927 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750908AbcI0MxN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 08:53:13 -0400
In-Reply-To: <baa46a3d-1f73-2f7e-6402-98763b159739@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> * Is it still correct nowadays that the function "gigaset_initcs" did not
>>   call the function "kfree" after a later function call failed?
> 
> Yes, if it is handled in another place, Paul already did show you the place.

To which source code place do you refer here?


>> * Do you expect that allocated memory will be automatically reclaimed
>>   after it would return a null pointer?
>>
> Of course not

Thanks for this acknowledgement.

Regards,
Markus
