From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] jumbo all-NICs ethtool count cleanup
Date: Sun, 16 Sep 2007 03:39:12 -0400
Message-ID: <46ECDDA0.3070701@garzik.org>
References: <20070916061015.GA11373@havoc.gtf.org> <20070916062722.GA5498@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34427 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbXIPHjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 03:39:13 -0400
In-Reply-To: <20070916062722.GA5498@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg wrote:
> Hi Jeff.
> 
> You wrote:
>> The hooks ->self_test_count() and ->get_stats_count() are now unused
>> in the main tree.
> 
> So I'm suprised to see more lines added than deleted:
>>  35 files changed, 346 insertions(+), 246 deletions(-)
> 
> Puzzled - may need a bit more coffee (morning here)..

The new interface that supercedes these is ->get_sset_count(), which was 
added to provide additional functionality without having to add a new 
hook each time we want to return a new integer value.  This new 
interface also (intentionally) aligns with the existing ->get_strings() 
interface.  ("sset" in get_sset_count stands for "string set")

	Jeff



