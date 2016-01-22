From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Has RFC4821 been implemented?
Date: Fri, 22 Jan 2016 22:19:41 +0100
Message-ID: <56A29CED.4090601@stressinduktion.org>
References: <CALx6S36MOrJpLQ0QU8vERHc4yW-dDzrqURStnnscVS6-0WiAKA@mail.gmail.com>
 <CALx6S361VWtUTASeEkkG3Cm3DaeQRCUfAe8fP3T+BjZqw8GGGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36352 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbcAVVTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 16:19:43 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 434272168A
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 16:19:43 -0500 (EST)
In-Reply-To: <CALx6S361VWtUTASeEkkG3Cm3DaeQRCUfAe8fP3T+BjZqw8GGGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 22.01.2016 20:50, Tom Herbert wrote:
> Found it: tcp_mtu_probing

Exactly.

> On Fri, Jan 22, 2016 at 11:39 AM, Tom Herbert <tom@herbertland.com> wrote:
>> This came up on in one of the IETF mailing lists in the context that
>> PMTUD doesn't really work on the Internet so  PLPMTUD is the way to
>> go. Looking at the code I only see inet_csk_update_pmtu called from
>> ICMP PTB error. I am missing something?

If I recall correctly we don't store the MSS in the inetpeer tcp metrics 
cache neither do we update the MTU on the specific path (update the 
dst_entry). So it is a one connection only thing so far.

Bye,
Hannes
