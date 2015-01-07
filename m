From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Wed, 7 Jan 2015 10:46:35 -0800
Message-ID: <CAHA+R7PJNFfekrLx6j+c+C4zsgVk1r5jm-hXv5=f4hLkq932pA@mail.gmail.com>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
	<54AD7C03.3010904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:43963 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbbAGSqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 13:46:36 -0500
Received: by mail-qg0-f50.google.com with SMTP id z60so1263597qgd.23
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 10:46:36 -0800 (PST)
In-Reply-To: <54AD7C03.3010904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 10:33 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 01/07/2015 05:43 PM, Jiri Pirko wrote:
>>
>> This action provides a possibility to exec custom BPF code.
>
>
> Can you elaborate a bit more on the particular use-case, and
> what scenarios are unsolveable with the BPF filter we already
> have in tc? Just wondering, since you're using BPF for the
> purpose of classifying (but just from the context of actions)
> what about a possibility of a generic container for reusing
> (any) classifier from the framework, so we would not need to
> duplicate code?
>

+1

Also as its name tells, BPF is a filter, why it could be used
as an action here? (I don't follow eBPF though.)
