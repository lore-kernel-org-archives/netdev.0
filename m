From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 07:29:34 -0500
Message-ID: <54C3902E.6080705@mojatatu.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org> <54C12C1F.706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: John Fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:40180 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbAXM3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 07:29:37 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so1760546igb.2
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 04:29:36 -0800 (PST)
In-Reply-To: <54C12C1F.706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry I have been running around like a lunatic chicken so havent
had time to join the fun discussion. I hope we can make progress at
the meeting.
I am going to skim and jump through the emails and comment.

On 01/22/15 11:58, John Fastabend wrote:
> On 01/22/2015 07:13 AM, Thomas Graf wrote:
>> On 01/22/15 at 10:00am, Jamal Hadi Salim wrote:

>
> Correct this is fully exposed to user space, but it is also self
> contained inside the API meaning I can learn when to use it and what it
> does by looking at the other operations tables the table graph and
> supported headers. The assumption I am making that is not in the API
> explicitly yet. Is that actions named "set_field_name" perform the
> set operation on that field. We can and plan to extend the API to make
> this assumption explicit in the API.
>

 From what you describe, you are running into a danger of going too low
level such that the interface will end up weighing too much into
flexibility/perfomance and less into usability. If there is one lesson
i learnt from netfilter is usability counts for something. You dont
want another u32 api (otherwise Jiri wouldnt have to write that new
classifier - there is nothing he is doing that cant be done with
u32).

> In this case I can "learn" that I can match on group_id in some tables
> and then use the above action to set the group_id in others.
>

And this discoverability was part of my concern especially when there is
no "stickiness" to the kernel or Linux tooling for that matter by
going direct to hardware. It is a tactical issue more than anything
else. With the approach, you need a little bit of clue of course, you 
really dont even care about compiling the kernel. Essentially the 
barrier to entry for SDKs is immensely lowered.
SDK joy. I know you were intending to replace ethtool - but you are
replacing it with a turbo engine and we need to look at a much bigger
scope.

cheers,
jamal
