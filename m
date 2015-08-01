From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Sun, 2 Aug 2015 00:48:19 +0300
Message-ID: <CAJ3xEMjgvgvc8WyUhHagiH4gNs6KK7pL_TmhXCywNiWEy4p70w@mail.gmail.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
	<CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
	<55BB6F10.5030408@redhat.com>
	<20150731163201.GA6027@obsidianresearch.com>
	<55BBB353.7020806@redhat.com>
	<CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
	<20150731220102.GA31209@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@avagotech.com>,
	Moni Shoua <monis@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33889 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbHAVsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 17:48:20 -0400
In-Reply-To: <20150731220102.GA31209@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 1, 2015 at 1:01 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Sat, Aug 01, 2015 at 12:24:23AM +0300, Or Gerlitz wrote:
>
>> addressed in incremental patch, as Doug suggested. Jason, it's wrong
>> to send developers again and again to fix things which were
>> perfect in Vn-1 but also not being covered by reviewers on Vn-1, at
>> some point the reviewer can't load new comments which gate the
>
> I don't even know what you are talking about Or.
>
> v6 had some small problems in the logic and v7 introduces a fairly
> serious flaw while trying to fix them. IMHO, you are better to merge
> v6 than v7, at least v6's problems are less likely to be serious.

Jason, can you be more specific? I don't see any comments from you
expect for the cover-letter, so if something broke out, sure, a fix is
needed, but what is that?

> That is the same argument you used for the timestamp _ex UAPI mess,
> last cycle, where are the incremental fixes for that?

I remember you have provided review comment which pointed that the
time-stamping series stepped on something which was there before needs
some cleanup, not a real mess to my taste. Matan, do have the plan to
do that work?

Or.
