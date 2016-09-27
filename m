From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [Gigaset307x-common] ISDN-Gigaset: Release memory in
 gigaset_initcs() after an allocation failure
Date: Tue, 27 Sep 2016 16:35:45 +0200
Message-ID: <1474986945.1654610.738520185.4722B74E@webmail.messagingengine.com>
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
 <02ad1fea-33f6-a38a-fd91-16bc0c351bdd@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <02ad1fea-33f6-a38a-fd91-16bc0c351bdd@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016, at 14:52, SF Markus Elfring wrote:
> >> * Is it still correct nowadays that the function "gigaset_initcs" did not
> >>   call the function "kfree" after a later function call failed?
> > 
> > Yes, if it is handled in another place, Paul already did show you the place.
> 
> To which source code place do you refer here?

Obviously the one Paul pointed out to you in detail in his mail dated
Mon, 26 Sep 2016 23:13:54 +0200.

HTH,
Tilman

-- 
Tilman Schmidt
tilman@imap.cc
