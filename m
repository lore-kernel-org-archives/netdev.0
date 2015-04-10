From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 09:48:15 -0400
Message-ID: <5527D49F.90201@mojatatu.com>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us> <20150409.173423.2258417584616634411.davem@davemloft.net> <20150410091203.GA2021@nanopsycho.orion> <5527981E.2040505@iogearbox.net> <20150410114633.GB2021@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36275 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965106AbbDJNsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 09:48:17 -0400
Received: by iebrs15 with SMTP id rs15so17542490ieb.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 06:48:16 -0700 (PDT)
In-Reply-To: <20150410114633.GB2021@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/15 07:46, Jiri Pirko wrote:
> Fri, Apr 10, 2015 at 11:30:06AM CEST, daniel@iogearbox.net wrote:
>> On 04/10/2015 11:12 AM, Jiri Pirko wrote:
>> ...

> I might be missing something, but to me, the codes of cls_flow and
> cls_openflow are very different. Merging cls_openflow with for example
> cls_fw makes similar sense to me.
>
> cls_flow is no match-action classifier. All skbs are hashed into classid
> of pre-defined range. You cannot speficy explicit action for match.
>
> On the other hand cls_openflow is match-action classifier (similar to
> for example bpf - might make more sense to me to merge it with bpf).
>
> What I say is, lets do things clearly, separate, not "overmerge" stuff.
>
> I will definitelly loose name "openflow" for my future submission to not
> to confuse people.
>

I think dropping the term "openflow" would be reasonable. I am not sure
if allowing for this to be part of cls_flow is reasonable.
I do think it makes sense to add another classifier that would do what
Dave was asking for. Such a classifier will have more advantages than
anything else imo since it will get most of the classification almost
for free.

cheers,
jamal
