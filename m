From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 07:17:45 +0100
Message-ID: <50FCDD89.3020403@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, stefanr@s5r6.in-berlin.de,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:39556 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3AUGRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 01:17:49 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so2749730eek.9
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 22:17:48 -0800 (PST)
In-Reply-To: <20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I'm no expert on firewire requirements, but if you go down the path
> of adding a net_device_ops member, I'd recommend adding a pointer
> to your own struct of ops.  This would be similar to wireless ops.
>
> Only a suggestion, since you may still need to add more ops later
> on, and this way you can contain the inflation to a firewire-specific
> struct of function pointers.
>

Thanks for your note. Right now I only need on function pointer for 
filling RFC3146 information and I can imagine doing the same for 
IPv4/ARP which would be a second function.

Stephan
