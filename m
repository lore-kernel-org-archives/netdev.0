From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 11:03:18 -0400
Message-ID: <20160527150318.GA25040@oracle.com>
References: <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
 <20160521174438.GA27990@oracle.com>
 <82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
 <20160522115605.GA30516@oracle.com>
 <CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
 <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
 <614c9a42-02c1-052a-52b6-289818bf757b@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35317 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222AbcE0PDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 11:03:33 -0400
Content-Disposition: inline
In-Reply-To: <614c9a42-02c1-052a-52b6-289818bf757b@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/27/16 11:53), Hannes Frederic Sowa wrote:
> > Thinking about this some more, the per option white list is a better
> > approach. If we allow an open ended mechanism for applications to
> > signal the network with arbitrary data (like user specified hbp
> > options would be), then use of that mechanism will inevitably
> > exploited by some authorities to force user to hand over private data
> > about their communications. It's better to not build in back doors to
> > security...
> 
> Sorry, Tom, can you try to explain again, I think I might not have
> understood you correctly.

yes, me too. Might help to discuss this by looking at an instance
of the type of option we are talking about. 

Usually hbh options are handled in the forwarding path (and thus
as unpopular as ip options, since they derail the packet to the 
slow path). Are you suggesting some type of AAA to vet the hbh 
option itself?

--Sowmini
