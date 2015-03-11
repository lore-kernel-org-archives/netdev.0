From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next] vlan: avoid a synchronize_net when parent device
 goes down
Date: Wed, 11 Mar 2015 15:02:44 -0700
Message-ID: <CAO7SqHA19qRPVO5knye3NE7WJXt7kSY-bvNaosaD40ZBCzaJFA@mail.gmail.com>
References: <1425598621-18083-1-git-send-email-noureddine@arista.com>
	<20150308.222134.544504915277666481.davem@davemloft.net>
	<CAO7SqHB=1+bQyU4Tt-RTkDYAU5GH_536hVfW1HU3jJz8iTySJQ@mail.gmail.com>
	<20150309.152211.2300226482423280727.davem@redhat.com>
	<CAO7SqHBbCgkhnXHf_=je_kir59uHBk5KKG0=AETPHRZN6hNfOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36252 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbbCKWCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:02:45 -0400
Received: by pdbnh10 with SMTP id nh10so14480202pdb.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 15:02:45 -0700 (PDT)
In-Reply-To: <CAO7SqHBbCgkhnXHf_=je_kir59uHBk5KKG0=AETPHRZN6hNfOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested your proposed patch and it seems to work as expected. Thanks!

On Mon, Mar 9, 2015 at 1:54 PM, Salam Noureddine <noureddine@arista.com> wrote:
> I will run your patch on one of our systems for a day or two and get
> back to you.
>
> On Mon, Mar 9, 2015 at 12:22 PM, David Miller <davem@redhat.com> wrote:
>> From: Salam Noureddine <noureddine@arista.com>
>> Date: Mon, 9 Mar 2015 12:00:31 -0700
>>
>>> Thanks for pointing to the right direction. Is there a reason the vlan
>>> driver was calling
>>> dev_change_flags instead of dev_close to close the vlan device?
>>
>> Perhaps dev_close() was not exported at the time the code was written,
>> I honestly have no idea.
