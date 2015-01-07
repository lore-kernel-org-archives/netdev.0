From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Do not use private netdev_vport fields
Date: Tue, 6 Jan 2015 22:00:21 -0800
Message-ID: <CALnjE+q6v-vOT7_j52LbytoFSy=fbKU=_MBrp2PWgX4rAKhCBA@mail.gmail.com>
References: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
	<CALnjE+odj6GdO97n4NBLQhP4egMzuNHMjxVqMwC7fSC5C=hT-g@mail.gmail.com>
	<20150106.170206.2121115629154170856.davem@davemloft.net>
	<CALnjE+ojw0FnonLyu8hhrWwcn_-_+EYtbFPWdCiJ-JC5h-L9eA@mail.gmail.com>
	<CALnjE+ormbwkh-=gjPA4iNP+n_dWP6JQxER1Rz6X-c1h8_Y6mw@mail.gmail.com>
	<CAExiqTLJG38DX_6C2Gaf6jE8-GThznML_-nkzs+57fU72QPW7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:36434 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751223AbbAGGAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 01:00:23 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so1981638iec.11
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 22:00:22 -0800 (PST)
In-Reply-To: <CAExiqTLJG38DX_6C2Gaf6jE8-GThznML_-nkzs+57fU72QPW7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 3:32 PM, Daniele Di Proietto
<daniele.di.proietto@gmail.com> wrote:
> The motivation for the change is to make datapath.c independent from
> the actual implementation of the vport. The problem came up when
> experimenting with other vport implementations and this type of change
> will help identifying layering violations.
> You are perfectly right, however, that in this form the code does not
> improve much: we should rather provide a vport_index() call, and
> implement one in each of the vports.
>

This sounds like lot more invasive change compared to the current
patch. For such change I need to see complete set of changes that you
are planning.


> Thoughts?
>
> 2015-01-06 23:28 GMT+01:00 Pravin Shelar <pshelar@nicira.com>:
>> On Tue, Jan 6, 2015 at 2:15 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> On Tue, Jan 6, 2015 at 2:02 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Pravin Shelar <pshelar@nicira.com>
>>>> Date: Tue, 6 Jan 2015 13:16:11 -0800
>>>>
>>>>> Function return type and function name should be on same line,
>>>>> otherwise looks good.
>>>>
>>>> I disagree, where is the code in the tree that needs this?
>>>
>>> Most of function definitions that I have seen are defined like this. I
>>> was pointing out coding style issue.
>>
>> About the actual change, I think it is a cleanup. netdev_vport_index()
>> hides the implementation from datapath.c. I hope Daniele will explain
>> need for the change.
