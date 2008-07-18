From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: READ ME, net-2.6 fully merged
Date: Fri, 18 Jul 2008 15:43:36 -0700
Message-ID: <9929d2390807181543q54c45e81lb890078fd51b11ea@mail.gmail.com>
References: <20080718.033947.193705552.davem@davemloft.net>
	 <20080718165128.GC10471@solarflare.com>
	 <20080718.141659.137928825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:12076 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760566AbYGRWnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 18:43:37 -0400
Received: by wa-out-1112.google.com with SMTP id j37so245510waf.23
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 15:43:37 -0700 (PDT)
In-Reply-To: <20080718.141659.137928825.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 2:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 18 Jul 2008 17:51:28 +0100
>
>> David Miller wrote:
>> >
>> > I merged Linus's current tree into net-next-2.6, fixed up all
>> > the merge conflicts, and pushed this out as plain "net-2.6":
>> >
>> >     master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>>
>> When I attempted to boot this on a test machine I got the following oops:
>
> Jeff Kirsher's patch I added should have cured this.
>
> Actually it won't, he fixed e1000ebut not e1000.
>
> Jeff?
> --

Yeah, it is the same issue.  It appears that Ben has already submitted
a similar patch to resolve the e1000 issue.

-- 
Cheers,
Jeff
