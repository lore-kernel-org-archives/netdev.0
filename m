From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Fri, 21 Aug 2009 20:03:26 +0900
Message-ID: <392fb48f0908210403o6a368ccby1a0b49fb34cb1f04@mail.gmail.com>
References: <4A65EC3F.4050400@gibraltar.at>
	 <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
	 <20090819174629.649f837f@nehalam>
	 <200908202237.43776.rene.mayrhofer@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:36483 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbZHULD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 07:03:26 -0400
Received: by fxm17 with SMTP id 17so398703fxm.37
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 04:03:27 -0700 (PDT)
In-Reply-To: <200908202237.43776.rene.mayrhofer@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/8/21 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:

> I've also tried the net-next-2.6 version of sky2.[ch] as of yesterday without
> Mike's "bandaid" patches. With that version (the last one in branch
> gibraltar-3.0 at https://www.gibraltar.at/git/linux-2.6-gibraltar.git), I
> managed to successfully do a networking restart (with "light" traffic on one
> interface), leaving the interfaces functional after the restart. This worked
> even twice in a row, so mabye we are onto something here. This is certainly an
> improvement over the version with Mike's last patch (from yesterday) applied,
> which left the interfaces broken after a restart (and with the quoted errors
> on a rmmod/modprobe sky2).
>
> However, after doing a ping -f on one of the (GBit) interfaces to another host
> on the same switch for a few seconds and then executing networking restart,
> the result was an immediate reboot of the box without any oops being printed
> to the (serial) console beforehand.

How about trying to remove the skge module, then running tests on the
sky2 interfaces only?  This way you might be able isolate the
remaining problems to sky2 or skge...?

thanks,

Mike
