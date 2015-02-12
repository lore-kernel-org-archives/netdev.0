From: Tom Marshall <tom@cyngn.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Wed, 11 Feb 2015 22:23:35 -0800
Message-ID: <20150212062335.GA12626@eden.sea.cyngn.com>
References: <20150212005844.GB3829@nwwn.com>
 <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150212052428.GB10785@eden.sea.cyngn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:58038 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbBLGXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 01:23:39 -0500
Received: by mail-pa0-f43.google.com with SMTP id fa1so9310094pad.2
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 22:23:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150212052428.GB10785@eden.sea.cyngn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> * UDP packets with dport=0 are already prevented from being sent.

FYI, I tried to trace where this code (disallowing udp packets with dport=0)
came from.  It predates git history, and I don't have any way to access
anything prior.
