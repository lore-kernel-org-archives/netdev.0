From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 18:46:45 +0200
Message-ID: <1464367605.681310.620746281.74E342B0@webmail.messagingengine.com>
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
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Tom Herbert <tom@herbertland.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33647 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbcE0Qqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:46:46 -0400
In-Reply-To: <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016, at 20:42, Tom Herbert wrote:
> Thinking about this some more, the per option white list is a better
> approach. If we allow an open ended mechanism for applications to
> signal the network with arbitrary data (like user specified hbp
> options would be), then use of that mechanism will inevitably
> exploited by some authorities to force user to hand over private data
> about their communications. It's better to not build in back doors to
> security...

Also I don't think that HbH options form some kind of hidden covert
channel. They mostly appear by unused fields which cannot be verified by
the other (receiving) side in any way.
