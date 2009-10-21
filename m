From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Tue, 20 Oct 2009 22:13:54 -0400
Message-ID: <20091020221354.5a714323.billfink@mindspring.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:32975 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbZJUCNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 22:13:50 -0400
In-Reply-To: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2009, Gilad Ben-Yossef wrote:

> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
> time stamp and window scale into per route entry feature options,
> laying the ground to future removal of the relevant global sysctls.
> 
> You really only want to disable SACK, DSACK, time stamp or window
> scale if you've got a piece of broken networking equipment somewhere 
> as a stop gap until you can bring a big enough hammer to deal with
> the broken network equipment. It doesn't make sense to "punish" the
> entire connections going through the machine to destinations not 
> related to the broken equipment.

For certain test situations, it is sometimes desirable to globally
disable TCP timestamps.  Although I have not personally wanted to
globally disable the other mentioned features, I can imagine test
scenarios where it could be useful.  Admittedly it could also be
accomplished with per route features, just not as conveniently,
especially if there are a large number of interfaces and/or routes.

						-Bill
