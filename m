From: Vinson Lee <vlee@twopensource.com>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Wed, 25 Mar 2015 12:39:01 -0700
Message-ID: <CAHTgTXVokVeq9Og6pEpRyhqtKuzFD4VHkMn_pnBUtt-V8ecxVA@mail.gmail.com>
References: <CAHTgTXX2rw9441stUb41EHTKanm9HZ+4T+a5+fur4O6G7zy21A@mail.gmail.com>
	<20150324.001408.1364899234285488351.davem@davemloft.net>
	<CAHTgTXWvDs4fTg_Gpsn8XrYnHbgZOKC4ymkq_QVdnGVCOaiqzw@mail.gmail.com>
	<20150325.140358.1369150767101881939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36585 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbbCYTjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:39:02 -0400
Received: by obdfc2 with SMTP id fc2so28196713obd.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:39:01 -0700 (PDT)
In-Reply-To: <20150325.140358.1369150767101881939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 11:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Vinson Lee <vlee@twopensource.com>
> Date: Wed, 25 Mar 2015 10:48:47 -0700
>
>> On Mon, Mar 23, 2015 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Vinson Lee <vlee@twopensource.com>
>>> Date: Tue, 17 Mar 2015 16:52:20 -0700
>>>
>>>> This stable request seems to have been forgotten.
>>>
>>> Sorry I've lost all of the context for this, you'll have to remind me
>>> of all of the details.
>>
>> These patches fixes warnings that can occur when a netconsole message
>> is transmitted in an IRQ.
>
> I mean the full context, as in the list of commits you'd like me to
> queue up for -stable, and what -stable releases they are relevant
> for.

Please backport the list of commits from the original stable request
at http://permalink.gmane.org/gmane.linux.network/320390.

The patches are from 3.15. Please queue them up for kernels <= 3.14.
