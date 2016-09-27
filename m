From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: ISDN-Gigaset: Release memory in gigaset_initcs() after an
 allocation failure
Date: Tue, 27 Sep 2016 11:34:01 +0200
Message-ID: <ad12e1a0-f5d5-176a-7d37-be2f3cb0af5d@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
 <0d02085e-842c-4be9-f706-c43b38ce9095@users.sourceforge.net>
 <1474966121.9970.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1474966121.9970.5.camel@tiscali.nl>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Will it matter here if the function "kfree" will be called for the
>> data structure members "bcs" and "inbuf" after a later function call
>> failed within the implementation of "gigaset_initcs"?
> 
> My translation of this question is: could you please hold my hand while
> I read the code of a driver I do not use - a driver for hardware that I
> don't even have, and therefor cannot really test - after I submitted a
> patch that appears to be broken?

I got the impression that the exception handling  was incomplete in the
implementation of the function "gigaset_initcs".
Does anybody (besides me) care for improving the software situation there?


> My answer to that question is: no, sorry, I won't do that.

I find that the process has just started once more to clarify in which
directions this software module could evolve.

Do we discuss a potential memory leak under special conditions here?

Regards,
Markus
