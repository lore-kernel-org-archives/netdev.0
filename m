From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] ip: fix igmp parsing when iface is long
Date: Tue, 17 Jan 2017 08:41:45 -0800
Message-ID: <20170117084145.720500c2@xeon-e3>
References: <20170116232550.7764-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34839 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdAQQlr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:41:47 -0500
Received: by mail-pg0-f48.google.com with SMTP id 194so25955529pgd.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:41:47 -0800 (PST)
In-Reply-To: <20170116232550.7764-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jan 2017 00:25:50 +0100
Petr Vorel <pvorel@suse.cz> wrote:

> Entries with long vhost names in /proc/net/igmp have no whitespace
> between name and colon, so sscanf() adds it to vhost and
> 'ip maddr show iface' doesn't include inet result.
> 
> Signed-off-by: Petr Vorel <pvorel@suse.cz>

Looks good, applied
