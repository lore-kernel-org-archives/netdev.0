From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Do not use private netdev_vport fields
Date: Tue, 6 Jan 2015 14:28:25 -0800
Message-ID: <CALnjE+ormbwkh-=gjPA4iNP+n_dWP6JQxER1Rz6X-c1h8_Y6mw@mail.gmail.com>
References: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
	<CALnjE+odj6GdO97n4NBLQhP4egMzuNHMjxVqMwC7fSC5C=hT-g@mail.gmail.com>
	<20150106.170206.2121115629154170856.davem@davemloft.net>
	<CALnjE+ojw0FnonLyu8hhrWwcn_-_+EYtbFPWdCiJ-JC5h-L9eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniele Di Proietto <daniele.di.proietto@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:44960 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751481AbbAFW2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:28:25 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so577199iec.1
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 14:28:25 -0800 (PST)
In-Reply-To: <CALnjE+ojw0FnonLyu8hhrWwcn_-_+EYtbFPWdCiJ-JC5h-L9eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 2:15 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Tue, Jan 6, 2015 at 2:02 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin Shelar <pshelar@nicira.com>
>> Date: Tue, 6 Jan 2015 13:16:11 -0800
>>
>>> Function return type and function name should be on same line,
>>> otherwise looks good.
>>
>> I disagree, where is the code in the tree that needs this?
>
> Most of function definitions that I have seen are defined like this. I
> was pointing out coding style issue.

About the actual change, I think it is a cleanup. netdev_vport_index()
hides the implementation from datapath.c. I hope Daniele will explain
need for the change.
