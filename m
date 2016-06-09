From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv4: Constrain UFO fragment sizes to multiples of 8 bytes
Date: Fri, 10 Jun 2016 00:39:11 +0200
Message-ID: <475a604a-6364-659c-afee-67e31005b17d@stressinduktion.org>
References: <6A051441C8B95A448E49718A747690B901CA76BE7B@gbplmail03.genband.com>
 <CAM_iQpUmts3gXa3cNSVxt=gVr-Erx5iAwoVhbEVgQqpGK6xLeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Steven Caron <steven.caron@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45603 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbcFIWjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 18:39:16 -0400
In-Reply-To: <CAM_iQpUmts3gXa3cNSVxt=gVr-Erx5iAwoVhbEVgQqpGK6xLeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.06.2016 06:59, Cong Wang wrote:
> (Cc'ing netdev...)
> 
> On Mon, Jun 6, 2016 at 1:24 PM, Steven Caron <steven.caron@genband.com> wrote:
>> Back in 2011, Bill Sommerfeld submitted an update to prevent ip_append_data to create malformed packets:
>>  Commit: d9be4f7a6f5a8da3133b832eca41c3591420b1ca
>>
>> Now we're finding that we need to apply the same logic to ip_append_page  to get nfs to work with udp when UFO is enabled:

Uhh, absolutely for the same reason as described in the referred commit.
 Can you send a patch?

Thanks,
Hannes
