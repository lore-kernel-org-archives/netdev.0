From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] diag: fix netlink API attributes
Date: Thu, 28 Nov 2013 18:37:08 +0100
Message-ID: <52977F44.6070002@6wind.com>
References: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com> <20131128163816.GA32047@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36770 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3K1RhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:37:12 -0500
Received: by mail-wi0-f182.google.com with SMTP id en1so1128203wid.9
        for <netdev@vger.kernel.org>; Thu, 28 Nov 2013 09:37:10 -0800 (PST)
In-Reply-To: <20131128163816.GA32047@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/11/2013 17:38, Thomas Graf a =E9crit :
> On 11/28/13 at 02:57pm, Nicolas Dichtel wrote:
>> The first netlink attribute (value 0) must always be defined as none=
/unspec.
>> This is correctly done in inet_diag.h, but other diag interfaces are=
 broken.
>>
>> Libraries like libnl skip this kind of attributes, thus it's never r=
eported to
>> the application.
>>
>> CC: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> First of all, thanks for the notification Nicolas. I'll fix libnl to
> pass through these attributes.
=46ine :)
Thank you!

>
> I think the fix you propose is no an option as it breaks backwards
> compatiblity with existing user space. We cannot change the value
> of existing attributes.
Yes, I was just wondering how to fix it.
It also breaks the patch you've proposed in this thread:
http://thread.gmane.org/gmane.linux.network/251478/focus=3D252764

Hence, aligning attributes on 64-bits is still unresolved :(
