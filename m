From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute equivalent of replacing address with ifconfig?
Date: Mon, 18 May 2015 10:46:58 -0700
Message-ID: <CAHA+R7Phpe3-ceX=zgWttfhguGWmBx9QQBtCyaGV6C3GOSdu9w@mail.gmail.com>
References: <5559F139.2010801@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33218 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbERRq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 13:46:59 -0400
Received: by wicmx19 with SMTP id mx19so94144796wic.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 10:46:58 -0700 (PDT)
In-Reply-To: <5559F139.2010801@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 7:03 AM, Michael Tokarev <mjt@tls.msk.ru> wrote:
>
> ip addr command however does not have the ability to "replace"
> an address, there are two commands for that, del and add.
> So in order to change address, one have to delete and add,
> a two-step process.  Adding an address before deleting might
> not work as the new address should not conflict with old
> address in any way, or else addition fails.

Are you sure?

$ ip addr help
Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]
                                                      [ CONFFLAG-LIST ]
[...]
