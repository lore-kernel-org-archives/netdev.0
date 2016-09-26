From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the sizeof
 operator by parentheses
Date: Mon, 26 Sep 2016 18:45:09 +0200
Message-ID: <d325c0ab-9f1b-e00d-6b4c-30f39d939ab4@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
 <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com>
 <1474907003.2238.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474907003.2238.13.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
>>>  {
>>>  	unsigned char outbuf[80];
>>>  	unsigned char c;
>>> -	size_t space = sizeof outbuf - 1;
>>> +	size_t space = sizeof(outbuf - 1);
> 
>> wrong ...
>> think that is 7 instead of 79.
> 
> 
> Well, it's sizeof(pointer) so either 4 or 8, but still,
> what Markus proposes here is _wrong_.

You are right at this place.


> Markus, do you know the script probably has a lower
> style conversion defect introduction rate than you do
> when doing these mechanical things.

Would it be nice if the script "checkpatch.pl" could avoid to point
such a false positive out anyhow?


> Please use it to verify what you are doing before
> submitting more defective patches.

Do you expect a resend for this update step so that an other statement
in the function "gigaset_initdriver" would eventually be adjusted?

Regards,
Markus
