From: Ani Sinha <ani@arista.com>
Subject: Re: tcpdump's capture filter: "vlan" doesn't match
Date: Thu, 16 Oct 2014 16:39:07 -0700
Message-ID: <CAOxq_8NXp7DnpWPKB1zkq-dv6WEJLgq+qLs_euWMjFxPP+UAow@mail.gmail.com>
References: <DUB123-W23D5ECAD4869F9A799E1F6EDAA0@phx.gbl> <543F616C.5040801@redhat.com>
 <DUB123-W25C5DA9BEDC92CD2524B68EDAB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Jesse Gross <jesse@nicira.com>,
	Michael Richardson <mcr@sandelman.ca>,
	Ani Sinha <ani@aristanetworks.com>, fenner <fenner@arista.com>
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:53101 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJPXj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 19:39:28 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so608968igc.12
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 16:39:27 -0700 (PDT)
In-Reply-To: <DUB123-W25C5DA9BEDC92CD2524B68EDAB0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+fenner.

I had spent some considerable time in the past looking into this and
proposing a patch :

http://seclists.org/tcpdump/2013/q1/0

However, there was no feedback and I got sucked into a different
project and this work fell through the cracks. If someone else picks
it up, I will be glad to help/lend a hand.

Cheers,
ani


On Thu, Oct 16, 2014 at 4:25 PM, Lukas Tribus <luky-37@hotmail.com> wrote:
>>> Isn't disabling rx-vlan-offloading supposed to remedy those problems?
>>
>> There were some discussions on this in the past e.g. [1]. We have
>> SKF_AD_VLAN_TAG and SKF_AD_VLAN_TAG_PRESENT for the BPF filter on
>> this, but libpcap is currently not making use of any of them.
>>
>> [1] http://thread.gmane.org/gmane.linux.network/247947
>
> Thanks for the link. I see the situation is unfortunate and although those
> new BPF filters in the kernel may fix the actual filtering problem, one
> thing seems to remain impossible: disabling all this kernel magic and
> passing the frame as-is to libpcap without interception (avoiding any
> kind of artificial header reconstruction).
>
> How is the situation with netsniff-ng anyway? Does it use vlan BPF filter
> in the kernel?
>
>
>
> Regards,
>
> Lukas
>
>
