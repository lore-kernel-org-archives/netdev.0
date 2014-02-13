From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 18:01:48 -0800
Message-ID: <87ob2b4voz.fsf@xmission.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140212083322.1559f441@nehalam.linuxnetplumber.net>
	<CAHA+R7NJ2uPbVdcdktD9R-_1QZnbwJXV+NP6jK0_ZTn=TF687g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56154 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbaBMCBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 21:01:55 -0500
In-Reply-To: <CAHA+R7NJ2uPbVdcdktD9R-_1QZnbwJXV+NP6jK0_ZTn=TF687g@mail.gmail.com>
	(Cong Wang's message of "Wed, 12 Feb 2014 17:20:16 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> writes:

> On Wed, Feb 12, 2014 at 8:33 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>>
>> This also breaks propogation of state changes from lower device
>> to upper device. Things like carrier and up/down.
>>
>
> macvlan_device_event() handles this pretty well by using a pointer to
> net_device.
> I don't see it is a problem from the code.

A quick grep shows two uses of iflink in net/core/link_watch.c that are
likely broken by your proposed change.

Eric
