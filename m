From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: BUG: TCPDUMP invalid cksum persists after disabling TCP cksum offload
Date: Tue, 18 Sep 2012 14:46:54 -0700
Message-ID: <CAGK4HS9LSAGJ4amNK-rWKFNz=ZCVLkQm4sWABhY5C+6DBWsmUA@mail.gmail.com>
References: <20120918193208.GA19030@darkstar>
	<1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	<20120918211423.GA19115@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:51353 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab2IRVqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 17:46:55 -0400
Received: by oago6 with SMTP id o6so402162oag.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 14:46:54 -0700 (PDT)
In-Reply-To: <20120918211423.GA19115@darkstar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The results after disabling tcp cksum offload feature:
> # ethtool -K eth1 tx off

Instead of this, can you try
# ethtool -K eth1 tso off


Vijay
