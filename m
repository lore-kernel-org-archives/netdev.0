From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 2/4] atlx: add atl2.h
Date: Tue, 09 Sep 2008 22:12:31 -0400
Message-ID: <48C72D0F.6020803@redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>	<20080909061945.GB18425@file.rdu.redhat.com> <20080909204300.43e38187@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52481 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbYIJCQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 22:16:14 -0400
In-Reply-To: <20080909204300.43e38187@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Tue, 9 Sep 2008 02:19:45 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
>> From: Chris Snook <csnook@redhat.com>
>>
>> Header file for atl2 support.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
> 
> Checkpatch.pl reports some coding style and whitespace issues.  
> 
> total: 83 errors, 46 warnings, 482 lines checked

Wow, that's actually better than I was expecting.  I'm posting it as-is because 
it's ridiculous for people to wait yet another release for this to hit mainline, 
just for cosmetic reasons.  People are using this driver all over the place, and 
nobody is working on fixing the initialization bugs and implementing ethtool 
ioctls while it's sitting in my kscope window waiting for me to clean up the 
rest of the whitespace.

I recommend we merge it anyway, though I admit it needs cleanup.

-- Chris
