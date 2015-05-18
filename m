From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: iproute equivalent of replacing address with ifconfig?
Date: Mon, 18 May 2015 21:13:45 +0300
Message-ID: <555A2BD9.9000606@msgid.tls.msk.ru>
References: <5559F139.2010801@msgid.tls.msk.ru> <CAHA+R7Phpe3-ceX=zgWttfhguGWmBx9QQBtCyaGV6C3GOSdu9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:50747 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063AbbERSNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 14:13:47 -0400
In-Reply-To: <CAHA+R7Phpe3-ceX=zgWttfhguGWmBx9QQBtCyaGV6C3GOSdu9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

18.05.2015 20:46, Cong Wang wrote:
> On Mon, May 18, 2015 at 7:03 AM, Michael Tokarev <mjt@tls.msk.ru> wrote:
>>
>> ip addr command however does not have the ability to "replace"
>> an address, there are two commands for that, del and add.
>> So in order to change address, one have to delete and add,
>> a two-step process.  Adding an address before deleting might
>> not work as the new address should not conflict with old
>> address in any way, or else addition fails.
> 
> Are you sure?
> 
> $ ip addr help
> Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]
>                                                       [ CONFFLAG-LIST ]

Hm.  I looked into the manpage, where neither change nor replace are
documented.  Wonder what these do, what's the difference etc...

Thanks!

/mjt
