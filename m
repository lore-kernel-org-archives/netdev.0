From: "Eugene Teo" <eugeneteo@kernel.sg>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Tue, 12 Aug 2008 09:28:05 +0800
Message-ID: <28fa9c5e0808111828w2a9f1133y75c785f70b683ff2@mail.gmail.com>
References: <20080809213101.0927a808.akpm@linux-foundation.org>
	 <489F8827.4030904@hp.com>
	 <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
	 <20080811.143212.172434871.davem@davemloft.net>
	 <48A0CEEA.9080104@hp.com>
	 <82e4877d0808111701k8cf8b5p60623a65eb6bda95@mail.gmail.com>
	 <48A0DC27.7030208@hp.com>
	 <28fa9c5e0808111810l63220abbgf9e747bad3a7fe44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Parag Warudkar" <parag.warudkar@gmail.com>,
	"David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.152]:12210 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbYHLB2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:28:07 -0400
Received: by po-out-1718.google.com with SMTP id c31so4004461poi.1
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 18:28:06 -0700 (PDT)
In-Reply-To: <28fa9c5e0808111810l63220abbgf9e747bad3a7fe44@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 9:10 AM, Eugene Teo <eugeneteo@kernel.sg> wrote:
> On Tue, Aug 12, 2008 at 8:41 AM, Brian Haley <brian.haley@hp.com> wrote:
>> Parag Warudkar wrote:
>>>
>>> What output do you see with your patch?
>>
>> # ip -f inet6 route get fec0::1
>> unreachable fec0::1 dev lo  table unspec  proto none  src
>> 2001:1890:1109:a10:218:feff:fe7f:49c8  metric -1  error -101 hoplimit 255
>
> Hmm, I tried it on an older kernel that doesn't have Yoshfuji-san's
> ipv6_get_saddr() changes,
> and it should display the output with the loopback MAC address instead
> of ethX MAC address.
> Correct me if I am wrong.

Evidence of me still sleepy. Not the MAC address but the ipv6 address...

Eugene
