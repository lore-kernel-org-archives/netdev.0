From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute2: ip netns: Do not delete netns if there any process use it
Date: Thu, 12 Mar 2015 09:48:33 -0700
Message-ID: <CAHA+R7P_v7Jc+-r6hPp9o_02iD1N_mPysW5dajDXdrpG4gD5rw@mail.gmail.com>
References: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
	<CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
	<20150311165011.GA917@angus-think.lan>
	<CAHA+R7PsYQLVXse5Yjk6K9V==Yw2WUM=rYGi1KPRf+bwZAwDxQ@mail.gmail.com>
	<20150312083106.GA1016@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36551 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbCLQsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:48:33 -0400
Received: by igkb16 with SMTP id b16so45783464igk.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 09:48:33 -0700 (PDT)
In-Reply-To: <20150312083106.GA1016@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 1:31 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> On Wed, Mar 11, 2015 at 10:07:50AM -0700, Cong Wang wrote:
>>
>> It is your responsibility to track the processes you put into the netns.
> Yes.
>
> I just was thinking that there is no reason to delete netns file
> when there are the processes that uses this netns, so some kind of safe
> validation would be helpful.

Deleting that bind mount file is just decreasing the refcount.
Essentially netns doesn't even have a name.

>
> But if no one think that it can be the right think then may be at least
> adding some explanation about this in ip-netns man page would be helpful.
>

Its name is gone, but it still exists as anonymous until the last reference
is gone.
