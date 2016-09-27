From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [Gigaset307x-common] ISDN-Gigaset: Release memory in
 gigaset_initcs() after an allocation failure
Date: Tue, 27 Sep 2016 12:26:02 +0200
Message-ID: <1474971962.1601897.738261385.73EB49E0@webmail.messagingengine.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
 <0d02085e-842c-4be9-f706-c43b38ce9095@users.sourceforge.net>
 <1474966121.9970.5.camel@tiscali.nl>
 <ad12e1a0-f5d5-176a-7d37-be2f3cb0af5d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Karsten Keil <isdn@linux-pingi.de>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad12e1a0-f5d5-176a-7d37-be2f3cb0af5d@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

as longtime maintainer of the code in question I feel compelled to chime
in at this point.

On Tue, Sep 27, 2016, at 11:34, SF Markus Elfring wrote:
> >> Will it matter here if the function "kfree" will be called for the
> >> data structure members "bcs" and "inbuf" after a later function call
> >> failed within the implementation of "gigaset_initcs"?
> > 
> > My translation of this question is: could you please hold my hand while
> > I read the code of a driver I do not use - a driver for hardware that I
> > don't even have, and therefor cannot really test - after I submitted a
> > patch that appears to be broken?
> 
> I got the impression that the exception handling  was incomplete in the
> implementation of the function "gigaset_initcs".

That impression is wrong. Careful reading of the code will confirm that.

> Does anybody (besides me) care for improving the software situation
> there?

There's no urgent need for improvement. The code is stable and there's
no demonstrated bug to be fixed.
You could improve the coding style, but that is of secondary importance,
and if you want to do that, as a minimum you have to make sure that you
don't introduce new bugs.

Thanks,
Tilman

-- 
Tilman Schmidt
tilman@imap.cc
