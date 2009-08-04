From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 05 Aug 2009 08:53:55 +0900
Message-ID: <4A78CA13.6040409@ring3k.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at> <4A78BD5F.2030901@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Rene Mayrhofer <rene@mayrhofer.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:10077 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933030AbZHDX4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 19:56:50 -0400
Received: by rv-out-0506.google.com with SMTP id k40so820628rvb.5
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:56:51 -0700 (PDT)
In-Reply-To: <4A78BD5F.2030901@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rene Mayrhofer wrote:

> Again, any hints would be greatly appreciated (and sorry for being
> persistent about this annoying little bug...).

Hi Rene,

Thanks for being persistent in testing :-)  Looks like you've got a 
fairly unusual piece of hardware, as Stephen indicated.

Would you mind adding the phy_lock fix on top of the latest net-2.6
git version of sky2 and testing that?

thanks,

Mike
