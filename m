From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Tue, 14 Nov 2006 15:41:55 +0100
Message-ID: <1163515315.2762.24.camel@ux156>
References: <ej09qf$2nv$1@sea.gmane.org> <200611111607.05420.mb@bu3sch.de>
	 <20061112012430.GA29648@keitarou> <200611120934.28133.mb@bu3sch.de>
	 <20061114142959.GA17486@keitarou>  <20061114144040.GA18175@keitarou>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24794 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965891AbWKNOkp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 09:40:45 -0500
To: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
In-Reply-To: <20061114144040.GA18175@keitarou>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 01:40 +1100, Paul TBBle Hampson wrote:

> bcm43xx-d80211 w/v3 firmware and WEP-104: Garbled _everything_ RX
> Of course, that's to be expected. WEP only uses broadcast keys, and
> we knew they were failing in software mode.

Hmm, not sure about this, but it sort of confirms my theory -- with v3
firmware we never upload keys to the hw so the hw will successfully
decrypt frames with the 'none' algorithm, and the RX path will treat
them as though they were decrypted already.

johannes
