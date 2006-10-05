From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wext
Date: Thu, 05 Oct 2006 10:15:10 +0200
Message-ID: <1160036110.2728.21.camel@ux156>
References: <200610021955.23112.chunkeey@web.de>
	 <1159951043.2817.36.camel@ux156>  <20061004214548.GQ10337@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chunkeey@web.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39888 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751217AbWJEIOV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 04:14:21 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061004214548.GQ10337@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 14:45 -0700, Jouni Malinen wrote:

> SIOCSIWMLME was designed to allow additional MLME commands to be added.
> IMHO, a potential replacement in the future should not prevent us from
> extending WEXT at this point and stop all changes in something that is
> currently available.

Fine with me, it's really just a matter of switch()ing on the
sub-command in the cfg80211-we compat code. My answer was more political
in nature I guess -- even I need sleep, you know. :P

johannes
