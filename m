From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: [PATCH v2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Tue, 22 Jan 2013 21:08:33 -0800
Message-ID: <877gn4iizy.fsf@blp.benpfaff.org>
References: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
	<20130122.205507.339713494072219737.davem@davemloft.net>
Reply-To: blp@cs.stanford.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-smtp-3.Stanford.EDU ([171.64.64.27]:53814 "EHLO
	cs-smtp-3.Stanford.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab3AWFpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:45:04 -0500
In-Reply-To: <20130122.205507.339713494072219737.davem@davemloft.net> (David
	Miller's message of "Tue, 22 Jan 2013 20:55:07 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 22 Jan 2013 14:56:38 -0800
>
>> Fixed code indentation according to comments from David Miller.
>> 
>> --8<--------------------------cut here-------------------------->8--
>
> This doesn't do what you think it does.  No automated tool is going
> to edit the commit message the way you think this will.

"git am" does if you run with --scissors, see git-am(1):

       -c, --scissors
           Remove everything in body before a scissors line (see git-
           mailinfo(1)).

and git-mailinfo(1);

       --scissors
           Remove everything in body before a scissors line. A line that
           mainly consists of scissors (either ">8" or "8<") and perforation
           (dash "-") marks is called a scissors line, and is used to request
           the reader to cut the message at that line. If such a line appears
           in the body of the message before the patch, everything before it
           (including the scissors line itself) is ignored when this option is
           used.

           This is useful if you want to begin your message in a discussion
           thread with comments and suggestions on the message you are
           responding to, and to conclude it with a patch submission,
           separating the discussion and the beginning of the proposed commit
           log message with a scissors line.

           This can enabled by default with the configuration option
           mailinfo.scissors.
