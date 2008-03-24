From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] 2.6.25-rc4 de_stop_rxtx polling wrong
Date: Sun, 23 Mar 2008 23:09:33 -0600
Message-ID: <20080324050933.GA9944@colo.lackof.org>
References: <20080309013316.GD25083@colo.lackof.org> <47DE605F.1060100@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:57684 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbYCXFJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 01:09:45 -0400
Content-Disposition: inline
In-Reply-To: <47DE605F.1060100@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 08:13:19AM -0400, Jeff Garzik wrote:
> Grant Grundler wrote:
>> Jeff,
>> This untested patch _should_ fix:
>> 	"(net de2104x) Kernel panic with de2104x tulip driver on boot"	
>> 	http://bugzilla.kernel.org/show_bug.cgi?id=3156
>> But the bug submitter isn't responding.  Same fix has been applied
>> to tulip.c (several years ago) and uli526x.c (Feb 2008) drivers.
>> Patch was originally against 2.6.23 but applies clean against 2.6.25-rc4.
>> [ The panic reported in the bug report was removed in a recently
>>   (march 2008) accepted patch from Ondrej Zary. ]
>> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
>
> applied

Thanks!

> Please include comments like "Jeff," and "Patch was originally[...]" after 
> the "---" separator, so that the automated tools may omit these comments 
> without human intervention.

Which separator is that? I didn't explicitly add one unless you are
referring to the patch itself.

Or tell me which automated tool you are using and I'd be happy to
figure out how to seperate logistical comments from what should
go in the "change log" (ie land in git history).

thanks,
grant
