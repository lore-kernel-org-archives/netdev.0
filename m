From: jamal <hadi@cyberus.ca>
Subject: Re: HTB/act_mirred problem [was: one more... iproute commands
	lockup whole system]
Date: Wed, 04 Apr 2007 10:33:22 -0400
Message-ID: <1175697202.4063.17.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
	 <20070404125231.M65138@visp.net.lb>  <4613B273.4070801@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:22957 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbXDDOdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:33:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so242752wxd
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 07:33:24 -0700 (PDT)
In-Reply-To: <4613B273.4070801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 16:13 +0200, Patrick McHardy wrote:

> This seems to be due to be caused by act_mirred returning TC_ACT_STOLEN,
> which is translated to NET_XMIT_SUCCESS within prio, causing HTB to
> increase the q.qlen counter and activating the class despite no packet
> beeing queued.
> 
> Jamal, we can't return NET_XMIT_SUCCESS unless we've really queued the
> packet. I can't remeber the reason why this is done, could you remind
> me?

IIRC, It had to do with not confusing TCP to try and retransmit. I can
go back and look at my notes to be certain. At one point i posted those
notes, it maybe time to add them to the kernel code or doc somewhere.

cheers,
jamal

PS:- i may a little slow in responding for the next few hours.

