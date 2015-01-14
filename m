From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2 v3] tc: add BPF based action
Date: Wed, 14 Jan 2015 16:55:07 +0100
Message-ID: <20150114155507.GC1869@nanopsycho.orion>
References: <1421229297-14473-1-git-send-email-jiri@resnulli.us>
 <54B66F08.2010305@redhat.com>
 <CAMEtUux+HOOegzyi82fYT_JMDX_+d0dZCQ=Zc5GWC-awQmJu1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:50144 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbbANPzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:55:19 -0500
Received: by mail-wg0-f50.google.com with SMTP id a1so9715383wgh.9
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 07:55:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMEtUux+HOOegzyi82fYT_JMDX_+d0dZCQ=Zc5GWC-awQmJu1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 14, 2015 at 04:39:34PM CET, ast@plumgrid.com wrote:
>On Wed, Jan 14, 2015 at 5:28 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>
>> I'm still wondering about the drop semantics ... wouldn't it be more
>> intuitive to use 0 for drops in this context?
>
>good point.
>I think it must be 0 to match behavior of socket filters, etc.
>If program tries to access beyond packet size or does divide
>by zero if will be terminated and will return 0.
>So zero should be the safest action from caller point of view.


Will do. Thanks!
