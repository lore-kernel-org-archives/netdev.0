From: Josh Clark <jcinma@gmail.com>
Subject: Re: Adding new packet scheduler
Date: Mon, 20 Oct 2014 13:51:18 -0400
Message-ID: <CAHmvzZS3bN1qErryz7Mps-dOveBk1_d7MJo-sqbVDMaoeu7_HA@mail.gmail.com>
References: <CAHmvzZQALDuwMPZC_ZncEP=BerniYis9Mx=oObUGNAY4wUGTZg@mail.gmail.com>
 <CAHA+R7PScLKyhF7V+RWahL1Ovfjb7eCO+Hh-aDYchPrfvAUDHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:44796 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaJTRwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 13:52:00 -0400
Received: by mail-ie0-f181.google.com with SMTP id at20so5233959iec.12
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 10:52:00 -0700 (PDT)
In-Reply-To: <CAHA+R7PScLKyhF7V+RWahL1Ovfjb7eCO+Hh-aDYchPrfvAUDHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 1:37 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Mon, Oct 20, 2014 at 10:32 AM, Josh Clark <jcinma@gmail.com> wrote:
>> Hi everyone,
>>
>> I'm a student at NC State University, and I'm working on a project to
>> implement some new classful AQM algorithms and test their
>> effectiveness. However, I'm getting hung up on how to get the new
>> algorithm set up in the kernel.
>>
>> From what I've looked at, it looks like I need to add my code to
>> /net/sched/, and edit both the Kconfig and the Makefile to be able to
>> add my code as another module.
>
> Basically yes, take a look at:
> http://lwn.net/Articles/577208/
>
>>
>> Finally, in order to use the new scheduler, I need to select it using
>> the tc command. What do I need to do to add my algorithm to the tc
>> command options?
>
> Read the existing qdisc's in tc, for example:
> http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/tc/q_fq.c

That all makes a lot of sense. What do I need to do to apply these
patches on a live system? I have access to a network made of virtual
machines with standard Ubuntu 14.04, to which I have SSH access.
There's no way for me to upload a different image to use.
