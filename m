From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] wext
Date: Wed, 4 Oct 2006 14:45:48 -0700
Message-ID: <20061004214548.GQ10337@instant802.com>
References: <200610021955.23112.chunkeey@web.de> <1159951043.2817.36.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chunkeey@web.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-42.dex002.intermedia.net ([64.78.21.132]:11365 "EHLO
	dhost002-42.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751169AbWJDVp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 17:45:57 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159951043.2817.36.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2006 at 10:37:23AM +0200, Johannes Berg wrote:
> On Mon, 2006-10-02 at 19:55 +0200, chunkeey@web.de wrote:
> > This patch (wext-patch) is a proposal. It adds two new defines for the 
> > SIOCSIWMLME to cover all kinds MLMEs (well, except REASSOC) through a ioctl.
> > (it would be nice to have them, so that I can post the hostapd code for the 
> > prism54 card!)
> 
> NACK from me. Please help me work on nl80211 instead :)

SIOCSIWMLME was designed to allow additional MLME commands to be added.
IMHO, a potential replacement in the future should not prevent us from
extending WEXT at this point and stop all changes in something that is
currently available.

-- 
Jouni Malinen                                            PGP id EFC895FA
