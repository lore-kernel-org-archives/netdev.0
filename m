From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 07:25:32 -0800
Message-ID: <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm> <5229621.KczjbIR22Q@storm>
	 <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8088599.PZmG8U31O2@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:63593 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbAOPZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 10:25:34 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so15512454iga.5
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 07:25:33 -0800 (PST)
In-Reply-To: <8088599.PZmG8U31O2@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 15:58 +0100, Thomas Jarosch wrote:

> A colleague mentioned to me he saw the "Hardware Unit Hang" message every 
> few days even running on kernel 3.4 (without your patch). Basically I'm 
> testing now if that's still the case with 3.19-rc4+ or not.
> 
> I'm all for fixing the root cause. I'm just interested if the e1000e
> hang can even be triggered when using a max frag page size of 4096.
> So far it transferred 751.6 GiB without a hiccup.

You told it was forwarding setup.

1) What is the NIC receiving traffic.
2) What happens if you disable GRO on it ?
