From: David Miller <davem@davemloft.net>
Subject: Re: netvsc merge conflicts...
Date: Tue, 07 Feb 2017 17:23:09 -0500 (EST)
Message-ID: <20170207.172309.929698282416047936.davem@davemloft.net>
References: <20170207.164141.2253747431048804570.davem@davemloft.net>
        <20170207141740.5a3c4ee9@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752404AbdBGWXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 17:23:17 -0500
In-Reply-To: <20170207141740.5a3c4ee9@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 7 Feb 2017 14:17:40 -0800

> On Tue, 07 Feb 2017 16:41:41 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> Stephen, I just did a merge of net into net-next and had to
>> resolve a merge conflict in the netvsc driver.
>> 
>> The problem was that in 'net' the hyperv bug fix that added
>> the calls to "init_cache_read_index()" in netvsc_channel_cb()
>> collided with your RX path cleanups.
>> 
>> Please double check my work and send me any needed fixups.
>> 
>> Thanks!
> 
> Sorry the init_cache_read_index came through greg's driver tree.
> Your merge cleanup matches what I was doing manually.

Great, thanks for checking it out for me.
