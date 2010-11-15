From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/6]: dccp ccid-2: Ack Vector patch set
 second/concluding part II
Date: Mon, 15 Nov 2010 11:04:59 -0800 (PST)
Message-ID: <20101115.110459.68121782.davem@davemloft.net>
References: <dccp_ccid2_ack_vector_patch_set_concluding_part_II>
	<1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932217Ab0KOTEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 14:04:34 -0500
In-Reply-To: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 07:29:01 +0100

> Hi Dave,
> 
> please find attached part II of the Ack Vector patch set, concluding
> the submission (part I) begun last week.
> 
>  Patch #1: algorithm to update/clear Ack Vector state in the circular buffer.
>  Patch #2: algorithm to register new packets as received in the circular buffer.
>  Patch #3: consolidates/updates Ack Vector processing in the main DCCP module.
>  Patch #4: schedules DCCP-Sync in case there is no space left for Ack Vectors.
>  Patch #5: removes the replaced parts of the old Ack Vector infrastructure.
>  Patch #6: Ack Vectors provide information specific to CCIDs; this patch thus
>            moves Ack Vector processing from main DCCP into the CCID module(s).
>  
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Pulled, thanks a lot Gerrit.

Some of the new functions you added had some coding style quirks,
for example the openning brace for dccp_ackvec_clear_state()
has an unnecessary space before it on that line.

Please fix those sorts of things up, thanks.
