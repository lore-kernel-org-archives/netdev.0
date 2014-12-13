From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 v4] ip: Simplify executing ip cmd within network
 ns
Date: Sat, 13 Dec 2014 16:20:24 +0100
Message-ID: <20141213152024.GB1849@nanopsycho.orion>
References: <1418422507-6635-1-git-send-email-vadim4j@gmail.com>
 <20141213082936.GA1849@nanopsycho.orion>
 <20141213084243.GA3284@angus-think.lan>
 <20141213085803.GA12446@angus-think.lan>
 <20141213133210.GA12291@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:56939 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaLMPU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 10:20:27 -0500
Received: by mail-wg0-f46.google.com with SMTP id x13so11426812wgg.33
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 07:20:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141213133210.GA12291@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 13, 2014 at 02:32:10PM CET, vadim4j@gmail.com wrote:
>On Sat, Dec 13, 2014 at 10:58:03AM +0200, vadim4j@gmail.com wrote:
>> On Sat, Dec 13, 2014 at 10:42:43AM +0200, vadim4j@gmail.com wrote:
>> > On Sat, Dec 13, 2014 at 09:29:36AM +0100, Jiri Pirko wrote:
>> > > Fri, Dec 12, 2014 at 11:15:07PM CET, vadim4j@gmail.com wrote:
>> > > >From: Vadim Kochan <vadim4j@gmail.com>
>> > > >
>> > > >Added new '-netns' option to simplify executing following cmd:
>> > > >
>> > > >    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>> > > >
>> > > >    to
>> > > >
>> > > >    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
>> > > >
>> > > >e.g.:
>> > > >
>> > > >    ip -net vnet0 link add br0 type bridge
>> > > >    ip -n vnet0 link
>> > > >
>> > > >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>> > > 
>> > > 
>> > > This looks good. I'm still missing support in tc, bridge, etc. I think
>> > > it would be great to do this in the same patch/patchset.
>> > > 
>> >  I planned to do this in the future patches after this main
>> >  changes will be accepted. Actually adding this option to other
>> >  tools is trivial.
>> > 
>> >  Anyway may be I will re-send v5 with supporting of these tools if I will have time.
>> > 
>> >  Regards,
>> 
>> BTW, some tools already have '-n' option, so I think only '-net' can be
>> used in such cases.


Yep, that is my point. I would like to have the same option for all.

>> 
>> Regards,
>
>OK, I am going to split changes into series of patches and bring new
>option to : ip, tc, and bridge tools.
>Regarding other misc tools - will do it later as I am  not very familiar with them.
>Are you OK with this Jiri ?

Yep. Thank you!

>
>Regards,
