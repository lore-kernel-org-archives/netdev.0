From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 09:14:51 -0700
Message-ID: <1431706491.27831.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	 <1431401204-731380-6-git-send-email-tom@herbertland.com>
	 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
	 <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515143506.GA5019@via.ecp.fr>
	 <1431701557.27831.103.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515152331.GA17375@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33580 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934820AbbEOQOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 12:14:54 -0400
Received: by pdbqa5 with SMTP id qa5so16143120pdb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 09:14:53 -0700 (PDT)
In-Reply-To: <20150515152331.GA17375@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 17:23 +0200, Sabrina Dubroca wrote:

> Sorry :(

No big deal, we are dealing with false positives here.

> 
> But I don't see how doing the same thing for
> __skb_checksum_validate_complete will address David's concerns.
> 
> I really have no problem with your submission, I just thought that it
> might not satisfy David.

The real problem/bug is with the flow label thing.

This needs a real fix.
