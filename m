From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Sun, 3 Jan 2016 13:13:15 +0100
Message-ID: <5689105B.50005@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686F0B2.5000000@users.sourceforge.net>
 <56870866.7020000@cogentembedded.com>
 <568785B3.5000905@users.sourceforge.net>
 <alpine.DEB.2.02.1601020914100.2063@localhost6.localdomain6>
 <5687939E.7010701@users.sourceforge.net> <5687A2C7.3000704@gmail.com>
 <5687B2BC.8090901@users.sourceforge.net> <5688EBAC.5000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5688EBAC.5000701-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>> What the patch tries to do is avoid the extra 'if (err)'.
>>
>> Yes. - I propose to look at related consequences together with the usage
>> of a popular short jump label once more.
> 
> When I read a subject saying "Better exception handling" it sounds like
> a functional improvement. Your change does not change anything
> functionally and may or may not save a bit of execution time depending
> on how smart the compiler is.

Can it eventually matter to skip another condition check in three cases?


> What you change does is confuse people reading the code.

A few software developers might find this proposal unusual.


> So please explain why your update improves exception handling here.
> I don't see it.

How does this feedback fit to the mentioned check avoidance?


> The code is not making the driver more robust against failures

That's true for this update suggestion.


> in this function, which is what I think of reading "better exception handling".

Other implementation details are affected by the shown fine-tuning.

Regards,
Markus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
