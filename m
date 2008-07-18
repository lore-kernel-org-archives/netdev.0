From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 12:16:26 +0300
Message-ID: <84144f020807180216mfd5e803o8f3f1a94b2db1a74@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
	 <20080718091146.GQ6875@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Vegard Nossum" <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net, johnpol@2ka.mipt.ru
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:44268 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbYGRJQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:16:26 -0400
Received: by rv-out-0506.google.com with SMTP id k40so258785rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 02:16:26 -0700 (PDT)
In-Reply-To: <20080718091146.GQ6875@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 12:11 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Pekka J Enberg <penberg@cs.helsinki.fi> wrote:
>
>> >   Object 0xf658ae70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>>
>> It's bit unfortunate that we don't see full dump of the corruption
>> here because SLUB limits the output to 128 bytes. Ingo, you might want
>> to try this patch so that we can see all of it:
>
> ok, applied this as a debug special to tip/out-of-tree - future
> incidents should have the full object dump.
>
> would makes sense for upstream too i think, or increase the limit to 4K
> or so. (which is still fair to be dumped into a syslog)

SLUB already limits object sizes to less than PAGE_SIZE so the patch
should be fine. Christoph, are you okay with this going upstream?
