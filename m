From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: Xilinx PowerPC
Date: Sun, 18 May 2008 22:09:43 -0600
Message-ID: <fa686aa40805182109j3e719e8fm8a176c4cc42eca1e@mail.gmail.com>
References: <480BA36D.1080000@dlasys.net>
	 <fa686aa40804201314m27caf4fau72956df9dd5d350d@mail.gmail.com>
	 <480BA821.2030109@dlasys.net>
	 <fa686aa40804201548o503e9b19p4081cec653a1acd2@mail.gmail.com>
	 <480BD66B.90001@dlasys.net> <JM200804230904046.2598203@co-nss.co.jp>
	 <482EFB8F.9090402@dlasys.net> <JV200805181113103.2504562@co-nss.co.jp>
	 <4830F388.3060709@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Yoshio Kashiwagi" <kashiwagi@co-nss.co.jp>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev <netdev@vger.kernel.org>
To: dhlii@dlasys.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:63761 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbYESEJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 00:09:44 -0400
Received: by an-out-0708.google.com with SMTP id d40so406214and.103
        for <netdev@vger.kernel.org>; Sun, 18 May 2008 21:09:43 -0700 (PDT)
In-Reply-To: <4830F388.3060709@dlasys.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 18, 2008 at 9:27 PM, David H. Lynch Jr. <dhlii@dlasys.net> wrote:
> I am preparing my own version of Yoshio's driver. Since most of my
> changes are re-ordering, renaming, or other items of small consequence,
> I will leave Yoshio as the author - unless he prefers otherwise.
>
> I hope to have it ready to submit as a patch in a few days.
> If Yoshio is unhappy with any of the changes I have made or chooses to
> submit his original code or some permutation I will withdrawl mine.
>
> While adding OF checksum offloading, ... would be nice,
> All I am looking to do is get something that can start its way into the
> kernel.
> This driver is working for me - with very light testing so far.
>
> If no one else is willing to Shepard something in, then I will try.
> Hints, clues, etc would be very much appreciated.
> I presume that if this driver is acceptable here, the next step would be
> forwarding it to linux-netdev ?

When you have a patch ready, post it both to here (linuxppc-dev) and
to netdev.  I'll provide review and help.  Most likely when it is
ready it will go in through jgarzik's tree, but if Jeff prefers, it
can go in via my Virtex tree.  Make sure you're able to generate and
send clean patches before you post it to the mailing lists (inline
instead of attachment, no line wrapping, applies cleanly to head of
tree).  If you need help, email me directly, and you can even send
test emails to me for me to check before posting to the list.

It doesn't have to be perfect before you submit, but you do need to be
prepared to respond to comments quickly and expect to respin the patch
several times.

Cheers,
g.

>
> Yoshio Kashiwagi wrote:
>> David-san,
>>
>> This driver must add some corrections, for example, Checksum-offloading
>> is incomplete as you say it. As for me, it is very happy to obtain
>> your cooperation. Let me know if I can be of any work for it.
>>
>> Moreover, although I wrote the xps_ll_temac driver for u-boot of a very
>> simple single SDMA descriptor, I have not got used and put in the
>> contribution way.
>>
>> Best Regards,
>> Yoshio Kashiwagi - Nissin Systems
>
> --
> Dave Lynch                                                  DLA Systems
> Software Development:                                    Embedded Linux
> 717.627.3770           dhlii@dlasys.net           http://www.dlasys.net
> fax: 1.253.369.9244                                Cell: 1.717.587.7774
> Over 25 years' experience in platforms, languages, and technologies too numerous to list.
>
> "Any intelligent fool can make things bigger and more complex... It takes a touch of genius - and a lot of courage to move in the opposite direction."
> Albert Einstein
>
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
