From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.23 0/2] cxgb3 - Fix dev->priv usage
Date: Wed, 29 Aug 2007 10:53:26 -0700
Message-ID: <46D5B296.8020703@chelsio.com>
References: <46D4F12C.7090409@chelsio.com> <ada3ay26gys.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28184 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbXH2RzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 13:55:02 -0400
In-Reply-To: <ada3ay26gys.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>
> Looks OK to me but I would just roll up the second patch into the
> first patch and let Jeff merge it as one commit.  There's no point in
> creating an intermediate tree that doesn't build -- it just breaks git
> bisect for no useful purpose.
>

Okay, Jeff agrees too, I'll do so.

> Also as a side note, when trying to test this I got the message
>
>     could not load TP SRAM: unable to load t3a_protocol_sram-1.0.44.bin
>
> and you guys seem to only have t3b protocol sram images on your web
> site.  Could you send me the t3a file (or swap out my T3A boards for
> T3B boards ;)?
>
I'd rather fix the driver then:
First, HW folks tell me that there is no need for engine
microcode update for T3A.
Moreover, there is a bug when the file name is constructed.
We have T3B and T3B2 board revs, the driver looks for
t3b_protocol_sram-1.0.44.bin for T3B2 boards and defaults to
t3a_protocol_sram-1.0.44.bin even for T3B boards.
I submitted a patch fixing this in netdev#upstream.
I should propose the fix for 2.6.23 instead.

Cheers,
Divy

