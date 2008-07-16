From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Wed, 16 Jul 2008 16:05:52 -0400
Message-ID: <20080716200552.GA28827@tuxdriver.com>
References: <20080714192302.GA2541@tuxdriver.com> <20080714.204532.116542087.davem@davemloft.net> <1ba2fa240807160549u68d9ecby25e79d832d772a0a@mail.gmail.com> <20080716.130007.11761812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tomasw@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4304 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757056AbYGPUbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 16:31:15 -0400
Content-Disposition: inline
In-Reply-To: <20080716.130007.11761812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 01:00:07PM -0700, David Miller wrote:
> From: "Tomas Winkler" <tomasw@gmail.com>
> Date: Wed, 16 Jul 2008 15:49:34 +0300
> 
> > On Tue, Jul 15, 2008 at 6:45 AM, David Miller <davem@davemloft.net> wrote:
> > > From: "John W. Linville" <linville@tuxdriver.com>
> > > Date: Mon, 14 Jul 2008 15:23:02 -0400
> > >
> > > drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 6 has type 's64'
> > > drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 7 has type 'u64'
> > 
> > I cannot reproduce this. Wasn't this conversion already solved or
> > still need to cast to long long int?
> 
> You have to cast u64/s64 values to long long if you want to print them
> using %llX specifiers, because some 64-bit platforms define these
> types as plain "long".

There were a number of such warnings fixed in iwlwifi previously.
It is possible that either one got lost in a merge conflict or this
new one simply is reminding Tomas of one of the old ones.  Either way,
it seems to be fixed now.

John
-- 
John W. Linville
linville@tuxdriver.com
