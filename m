From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] ip: fix igmp parsing when iface is long
Date: Tue, 17 Jan 2017 08:41:30 -0800
Message-ID: <20170117084130.7be84c38@xeon-e3>
References: <20170116232550.7764-1-pvorel@suse.cz>
        <20170117080809.4vtpebykeciemuo5@dell5510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35638 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdAQQld (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:41:33 -0500
Received: by mail-pf0-f178.google.com with SMTP id f144so63232721pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:41:33 -0800 (PST)
In-Reply-To: <20170117080809.4vtpebykeciemuo5@dell5510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jan 2017 09:08:09 +0100
Petr Vorel <pvorel@suse.cz> wrote:

> Hi,
> 
> > Entries with long vhost names in /proc/net/igmp have no whitespace
> > between name and colon, so sscanf() adds it to vhost and
> > 'ip maddr show iface' doesn't include inet result.  
> 
> Bug was also reported to bugzilla (https://bugzilla.kernel.org/show_bug.cgi?id=192741),
> with updated comment in the patch.
> 
> 
> Kind regards,
> Petr

Kernel bugzilla is irrelevant and ignored by network developers.
