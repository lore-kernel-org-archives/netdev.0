From: Jonas Bonn <jonas@southpole.se>
Subject: Re: PowerPC toolchain for x86 [Was: pci_device_id cleanups]
Date: Wed, 20 Feb 2008 15:03:30 +0100
Message-ID: <47BC3332.7090705@southpole.se>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se> <20080220131704.GB18790@uranus.ravnborg.org> <47BC2AB7.4040402@southpole.se> <20080220135533.GA19024@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	greg@kroah.com, Andrew Morton <akpm@linux-foundation.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:39966 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbYBTODc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 09:03:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 7B0F64ED0FD
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 15:03:31 +0100 (CET)
In-Reply-To: <20080220135533.GA19024@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Sam Ravnborg wrote:
> On Wed, Feb 20, 2008 at 02:27:19PM +0100, Jonas Bonn wrote:
>> Sam Ravnborg wrote:
>>> On Wed, Feb 20, 2008 at 01:53:36PM +0100, Jonas Bonn wrote:
>>>> The PCI_DEVICE_TABLE patch I sent earlier doesn't necessarily make
>>>> much sense by itself... here is a set of patches that apply
>>>> this macro, in turn moving a lot of this data into __devinitconst
>>>> which is discardable in certain situations.
>>>> Hopefully the benefit of this approach is a bit clearer now.
>>> [shorter lines please..]
>> Sorry...
>>
>>> Can you please confirm that this does not break powerpc (64 bit)
>>> as they have troubles with the constification..
>> I do not have access to any PowerPC machine... Olof Johansson built the 
>> tree I posted earlier on PowerPC; there's nothing really new here except 
>> the wrapping of the definition in a macro.
> And you added const and a specific section.

No... once the macro is expanded the code is exactly the same as that 
which built cleanly on powerpc previously (which Olof, built, I mean)... 
nothing new here.

> Exactly what could break on PowerPC.
> 
> To do the build break check is easy.
> Google for "crosstool" and build your own powerpc toolchain.
> 

Thanks... I'll throw together a cross compiler and see what I can do.

/Jonas

> Andrew has something precompiled somewhere but I lost the link.
> 
> 
> 	Sam
> 

