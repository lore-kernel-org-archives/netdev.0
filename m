From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: bonding directly changes underlying device address
Date: Thu, 15 May 2014 15:37:17 +0300
Message-ID: <CAJZOPZKMWD+EM9NX22ttQNQdsir3Skqhm7Et0+_OFRyh4mwtcw@mail.gmail.com>
References: <5371FCD0.7050502@mellanox.com>
	<20140513115527.GC2910@minipsycho.orion>
	<20030.1399998641@localhost.localdomain>
	<CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com>
	<20140514080114.GA30960@mikrodark.usersys.redhat.com>
	<5046.1400117925@localhost.localdomain>
	<20140515045524.GA27773@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:50199 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaEOMhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 08:37:18 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so1579513qgd.15
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 05:37:18 -0700 (PDT)
In-Reply-To: <20140515045524.GA27773@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 7:55 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> On Wed, May 14, 2014 at 06:38:45PM -0700, Jay Vosburgh wrote:
> ...snip...
>
>>         So, I'd say "No" to conversion to dev_set_mac_address() and
>> "show me the code" to the "stash it in the slave" plan.
>
>
> Ok, got it, I will try to move it to struct slave.

Good, and following that we'll see if/what remains on our mlx4_en/any
driver plate to fix under the TLB use case (hopefully none..)
