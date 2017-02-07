From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: netvsc merge conflicts...
Date: Tue, 7 Feb 2017 14:17:40 -0800
Message-ID: <20170207141740.5a3c4ee9@xeon-e3>
References: <20170207.164141.2253747431048804570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34761 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932738AbdBGWRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 17:17:48 -0500
Received: by mail-pg0-f49.google.com with SMTP id 14so42237975pgg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 14:17:48 -0800 (PST)
In-Reply-To: <20170207.164141.2253747431048804570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Feb 2017 16:41:41 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> Stephen, I just did a merge of net into net-next and had to
> resolve a merge conflict in the netvsc driver.
> 
> The problem was that in 'net' the hyperv bug fix that added
> the calls to "init_cache_read_index()" in netvsc_channel_cb()
> collided with your RX path cleanups.
> 
> Please double check my work and send me any needed fixups.
> 
> Thanks!

Sorry the init_cache_read_index came through greg's driver tree.
Your merge cleanup matches what I was doing manually.
