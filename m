From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute equivalent of replacing address with ifconfig?
Date: Mon, 18 May 2015 21:24:29 +0300
Message-ID: <20150518182429.GA894@angus-think.lan>
References: <5559F139.2010801@msgid.tls.msk.ru>
 <CAHA+R7Phpe3-ceX=zgWttfhguGWmBx9QQBtCyaGV6C3GOSdu9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Network Development <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33016 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636AbbERSZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 14:25:16 -0400
Received: by lagr1 with SMTP id r1so150739557lag.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 11:25:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7Phpe3-ceX=zgWttfhguGWmBx9QQBtCyaGV6C3GOSdu9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 10:46:58AM -0700, Cong Wang wrote:
> On Mon, May 18, 2015 at 7:03 AM, Michael Tokarev <mjt@tls.msk.ru> wrote:
> >
> > ip addr command however does not have the ability to "replace"
> > an address, there are two commands for that, del and add.
> > So in order to change address, one have to delete and add,
> > a two-step process.  Adding an address before deleting might
> > not work as the new address should not conflict with old
> > address in any way, or else addition fails.
> 
> Are you sure?
> 
> $ ip addr help
> Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]
>                                                       [ CONFFLAG-LIST ]
Ha, but man page does not have it :)
