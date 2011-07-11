From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 14:10:28 -0700
Message-ID: <20110711141028.19f0de46@nehalam.ftrdhcpuser.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
	<20110711130729.607d461e@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
	<20110711134938.5178797c@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Greg Scott" <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49978 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964817Ab1GKVK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 17:10:28 -0400
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2011 16:08:14 -0500
"Greg Scott" <GregScott@Infrasupport.com> wrote:

> > What about console dmesg output.
> 
> I should probably turn off all firewall logging so I don't fill the ring
> buffer with my log messages in, like, the first couple minutes after a
> boot.  :)
> 
> > Please retest with a standard upstream kernel (like 2.6.39.2).
> 
> That's gonna take a while to put together a whole test environment with
> the latest kernel.org kernel.
> 
> > The bridge itself puts the device into promiscuous mode already.

The bridge code calls dev_set_promiscuity() which should
be changing device mode. But it could be that netdev core is 
resetting/changing/breaking that.

