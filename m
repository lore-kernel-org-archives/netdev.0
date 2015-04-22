From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 3/3] tc: cleanup tc_classify
Date: Wed, 22 Apr 2015 16:38:04 -0700
Message-ID: <CAHA+R7Mzz-6j1u=6KqVgT1pesbWcon+=EZcsVU6VX7wm1zEUVg@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-4-git-send-email-ast@plumgrid.com>
	<CAHA+R7OSVs1rYcXkOM=FYoDMHGM30iWRRAVtdiJmU7jz9GRdYw@mail.gmail.com>
	<55382055.1090207@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36611 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbDVXiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 19:38:05 -0400
Received: by wizk4 with SMTP id k4so196364732wiz.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 16:38:04 -0700 (PDT)
In-Reply-To: <55382055.1090207@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 3:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 4/21/15 10:05 PM, Cong Wang wrote:
>>
>> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com>
>> wrote:
>>>
>>> introduce tc_classify_act() and qdisc_drop_bypass() helper functions to
>>> reduce
>>> copy-paste among different qdiscs
>>
>>
>>
>> I don't think qdisc_drop_bypass() is more readable than without it,
>> maybe you need a better name, or just leave the code as it is.
>
>
> what would be a better name? I'm open to suggestions.

My reading for "qdisc_drop_bypass()" is it bypasses packet
dropping for some case, apparently doesn't match its definition.

I can't think out a better name therefore I don't think it deserves
a function, just leave as it is.
