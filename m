From: Tom Herbert <tom@herbertland.com>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 10:05:57 -0700
Message-ID: <CALx6S37F3_SGRH24CrjT8Raot9oPb-LpJ-fU7HGnHUAPL5KUPg@mail.gmail.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
	<1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
	<20160521015604.GD2452@oracle.com>
	<1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
	<CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
	<6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
	<CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
	<f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
	<20160521174438.GA27990@oracle.com>
	<82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
	<20160522115605.GA30516@oracle.com>
	<CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
	<CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
	<1464367605.681310.620746281.74E342B0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34975 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcE0RF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 13:05:58 -0400
Received: by mail-io0-f174.google.com with SMTP id p64so34936370ioi.2
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 10:05:58 -0700 (PDT)
In-Reply-To: <1464367605.681310.620746281.74E342B0@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 9:46 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, May 26, 2016, at 20:42, Tom Herbert wrote:
>> Thinking about this some more, the per option white list is a better
>> approach. If we allow an open ended mechanism for applications to
>> signal the network with arbitrary data (like user specified hbp
>> options would be), then use of that mechanism will inevitably
>> exploited by some authorities to force user to hand over private data
>> about their communications. It's better to not build in back doors to
>> security...
>
> Also I don't think that HbH options form some kind of hidden covert
> channel. They mostly appear by unused fields which cannot be verified by
> the other (receiving) side in any way.

It would be pretty easy to make it that. All a network operator would
need to do is strip their proprietary options on egress from their
network. So a receiver, say our servers at FB, would have no way to
determine that our clients are being manipulated.

Tom
