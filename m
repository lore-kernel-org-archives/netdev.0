From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: ISDN-CAPI: Adjust 17 function calls together with variable
 assignments
Date: Mon, 26 Sep 2016 14:28:58 +0200
Message-ID: <16c50966-66f2-8a08-0ebc-936b04311f14@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
 <10355972-1c9b-1103-edf3-efde78237cdd@users.sourceforge.net>
 <1474881174.1846.8.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474881174.1846.8.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The script "checkpatch.pl" can point out that assignments should usually
>> not be performed within condition checks.
>> Thus move the assignment for a variable to a separate statement
>> in four functions.
> 
> Did you recycle this commit explanation?

Yes. - I am going to use similar commit messages for further changes
in other software modules.


> Because git diff tells me you actually touched about eight functions.

You are right. - I'm sorry that I overlooked to update this number somehow.


>     scripts/checkpatch.pl -f drivers/isdn/capi/capidrv.c | grep "assignment in if condition" | wc -l 
> 
> It tells me there are actually 18 instances of this "ERROR".
> Why did you ignore one of it in this patch?

Did I accidentally leave another update candidate over?

* How do you think about to pick such a software update opportunity up?

* Do you expect a resend for the steps 3 - 5 of this small patch series?

Regards,
Markus
