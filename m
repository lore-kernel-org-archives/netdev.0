From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 5/9] bonding: create a macro for bond mode
 and use it
Date: Thu, 15 May 2014 20:14:36 +0200
Message-ID: <20140515181436.GA25181@mikrodark.usersys.redhat.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
 <1400156967-8231-6-git-send-email-vfalico@gmail.com>
 <10028.1400176311@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:42348 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbaEOSO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:14:58 -0400
Received: by mail-wi0-f182.google.com with SMTP id r20so4684628wiv.9
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 11:14:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <10028.1400176311@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 10:51:51AM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@gmail.com> wrote:
>
>>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>>---
...snip...
>	Would it be better to use "bond_uses_primary(struct bonding *)"
>instead of the above?  That would simplify the above calling pattern,
>and shorten the calls elsewhere.  Maybe I missed one, but it looks like
>all of the calls to _uses_primary have BOND_MODE(bond) as the argument.

There's at least one call, when checking the params, where it checks the
int:

bond_main.c:
4271         if (primary && !bond_mode_uses_primary(bond_mode)) {

so, either we'll use something else here, or leave it with BOND_MODE()...
