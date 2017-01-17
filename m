From: Petr Vorel <pvorel@suse.cz>
Subject: Re: [PATCH 1/1] ip: fix igmp parsing when iface is long
Date: Tue, 17 Jan 2017 09:08:09 +0100
Message-ID: <20170117080809.4vtpebykeciemuo5@dell5510>
References: <20170116232550.7764-1-pvorel@suse.cz>
Reply-To: Petr Vorel <pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54711 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750929AbdAQIXu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 03:23:50 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 25D54ACE4
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:08:10 +0000 (UTC)
Content-Disposition: inline
In-Reply-To: <20170116232550.7764-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Entries with long vhost names in /proc/net/igmp have no whitespace
> between name and colon, so sscanf() adds it to vhost and
> 'ip maddr show iface' doesn't include inet result.

Bug was also reported to bugzilla (https://bugzilla.kernel.org/show_bug.cgi?id=192741),
with updated comment in the patch.


Kind regards,
Petr
