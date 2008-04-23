From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 06:00:18 +0000
Message-ID: <20080423060018.GA3946@ff.dom.local>
References: <20080422160130.0b84959a@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:41824 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbYDWF50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 01:57:26 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2476591fgb.17
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 22:57:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080422160130.0b84959a@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23-04-2008 01:01, Stephen Hemminger wrote:
...
>>>> First off, no hardware should ever do LRO on non-local packets. If the
>>>> hardware isn't smart enough to do this, I guess the bridge code to have
>>>> an API to turn it off. IP should also turn it off if ip_forwarding
>>>> is enabled on that device.

Could you explain this more? (I can't see any obvious reason why
forwarding between local networks should differ here from bridging?)

Thanks,
Jarek P.
