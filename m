From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: ISDN-Gigaset: Enclose two expressions for the sizeof operator by
 parentheses
Date: Mon, 26 Sep 2016 20:00:11 +0200
Message-ID: <eddce408-a4ee-7968-cd07-160497fa32ed@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
 <248e685c-4875-7acc-afaf-8b2ce00bb5f5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <248e685c-4875-7acc-afaf-8b2ce00bb5f5@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
>>  {
>>      unsigned char outbuf[80];
>>      unsigned char c;
>> -    size_t space = sizeof outbuf - 1;
>> +    size_t space = sizeof(outbuf - 1);
> 
>    What?! Does that compile?

Yes, of course. - The calculated value will be lower than intended.

Unfortunately, I stumbled on one of my own programming mistakes once again.


I sent a corrected update suggestion for further considerations a few minutes ago.

Regards,
Markus
