From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: New GIT net tree naming...
Date: Mon, 12 May 2008 14:47:15 -0400
Message-ID: <20080512184715.GA18910@tuxdriver.com>
References: <20080419.173510.257216556.davem@davemloft.net> <20080508014358.GE3412@tuxdriver.com> <200805080906.29603.hs4233@mail.mn-solutions.de> <20080508144046.GA3515@tuxdriver.com> <1ba2fa240805121039u1fc4273eh706c8868748b500c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Holger Schurig <hs4233@mail.mn-solutions.de>,
	linux-wireless@vger.kernel.org, David Miller <davem@davemloft.net>,
	sfr@canb.auug.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2651 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbYELTad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 15:30:33 -0400
Content-Disposition: inline
In-Reply-To: <1ba2fa240805121039u1fc4273eh706c8868748b500c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2008 at 08:39:22PM +0300, Tomas Winkler wrote:

> How would you want me to handle bug fixes to go both directions
> wireless-testing and upstream?
> Because of huge code movement we are now doing in iwlwifi they are
> currently just not the same.
> Shell I send two versions or you want to back port them not sure how
> do you want to track this...somewhere in merging loop it will create a
> conflict.  Maybe this is maintainer trivia anyhow
> I would like to make sure there are not glitches.

It is a good question -- thanks for asking!

If you think that two versions of the fix are appropriate, then please
do send them.  If it is simply because the code moved I'll probably
be able to figure it out, but if the code has actually changed it
may be worthwhile.

We are now trying to avoid rebasing "-next" patches as much as possible.
So the version for the current release will be merged to Linus and I or
Dave will have to figure-out how to resolve the merge conflicts when
current is pulled to -next.  Providing a "-next' version of the patch
can help to make sure that those merge conflicts are handled correctly.

John
-- 
John W. Linville
linville@tuxdriver.com
