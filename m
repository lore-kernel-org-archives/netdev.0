From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 06:31:27 -0800
Message-ID: <1416234687.5102.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1E54@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Serey Kong <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:51020 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbaKQObY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 09:31:24 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so5183966ier.28
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 06:31:23 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F1E54@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 14:15 +0000, David Laight wrote:

> Didn't someone write a function that significantly reduces the
> number of fragments without actually requiring a single linear block?

I presume you refer to alloc_skb_with_frags() : It does the allocation,
but I was expecting some kind soul to continue my work and provide the
companion code to do the copy.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=2e4e44107176d552f8bb1bb76053e850e3809841

So far nobody took care of it.
