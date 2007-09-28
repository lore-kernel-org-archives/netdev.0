From: Greg KH <greg@kroah.com>
Subject: Re: [stable] Upgrading 2.6.21.7->2.6.22.9 kills my network (sky2):
	sky2 eth0: rx error, status 0x402300 length 60
Date: Fri, 28 Sep 2007 09:13:28 -0700
Message-ID: <20070928161328.GB28246@kroah.com>
References: <Pine.LNX.4.64.0709280950160.17152@bizon.gios.gov.pl> <Pine.LNX.4.64.0709281144530.17152@bizon.gios.gov.pl> <Pine.LNX.4.64.0709281304590.17152@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33102 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbXI1QTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:19:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709281304590.17152@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 01:11:27PM +0200, Krzysztof Oledzki wrote:
>
>
> On Fri, 28 Sep 2007, Krzysztof Oledzki wrote:
>
>>
>>
>> On Fri, 28 Sep 2007, Krzysztof Oledzki wrote:
>>
>>> Hello,
>>> After upgrading my kernel from 2.6.21.7 to 2.6.22.9 my 88E8053 no longer 
>>> works:
>>
>> Small update: 2.6.22.9 with sky2.c/sky2.h from 2.4.22.4 works without any 
>> problems.
>
> Final update.
>
> Reverting this patch: 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.22.y.git;a=commitdiff_plain;h=8c07a8e30ba8a2e0831da4b134202598435f8358
> solved my problem.
>
> I also found this one:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=d6532232cd3de79c852685823a9c52f723816d0a
>
> Could it go to a next -stable ASAP, please? It seems that 2.6.22.5-2.6.22.9 
> kernels have broken sky2 if used with vlans. :( Such regression in a 
> -stable kernel isn't nice. :(

So should we just apply the second patch?  I'll let Stephen tell us what
we should do :)

thanks,

greg k-h
