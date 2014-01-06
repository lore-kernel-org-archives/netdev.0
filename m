From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: netdev_kobject_init: annotate with __init
Date: Mon, 06 Jan 2014 21:13:41 +0400
Message-ID: <52CAE445.5080201@cogentembedded.com>
References: <1388967611-14263-1-git-send-email-dborkman@redhat.com> <52CAC804.9080603@cogentembedded.com> <52CAD74B.6070602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:47354 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaAFRNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 12:13:43 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so9852561lbi.24
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 09:13:42 -0800 (PST)
In-Reply-To: <52CAD74B.6070602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.01.2014 20:18, Daniel Borkmann wrote:

>>> netdev_kobject_init() is only being called from __init context,
>>> that is, net_dev_init(), so annotate it with __init as well, thus
>>> the kernel can take this as a hint that the function is used only
>>> during the initialization phase and free up used memory resources
>>> after its invocation.

>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> [...]

>>> diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
>>> index bd7751e..2745a1b 100644
>>> --- a/net/core/net-sysfs.h
>>> +++ b/net/core/net-sysfs.h
>>> @@ -1,7 +1,7 @@
>>>   #ifndef __NET_SYSFS_H__
>>>   #define __NET_SYSFS_H__
>>>
>>> -int netdev_kobject_init(void);
>>> +int __init netdev_kobject_init(void);

>>     There's no need to also annotate function prototype.

> Hm, is that general convention?

    More or less, though I've seen some prototypes annotated.

> Having this in a header file
> annotated (even if not strictly necessary) would probably
> better prevent from possible misuse resp. section mismatches
> if people forget to look into the actual c file where the
> function is being defined.

    Dunno about vi users, I'm using Alt-. in EMACS when I want to find a 
function, and it gets me right to the definition, not the prototype.

>> WBR, Sergei

PS: The patch was merged already, so my comment seems to have been posted too 
late anyway.

WBR, Sergei
