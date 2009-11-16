From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 04:29:49 -0500
Message-ID: <1258363789.3251.30.camel@bigi>
References: <412e6f7f0911160056k6718dd55w6dcd7c7e673459c4@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:33190 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbZKPJ3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:29:46 -0500
Received: by qyk4 with SMTP id 4so2502017qyk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:29:52 -0800 (PST)
In-Reply-To: <412e6f7f0911160056k6718dd55w6dcd7c7e673459c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 16:56 +0800, Changli Gao wrote:
> act_mirred: optimization.
> 
> 1. move checking if eaction is valid in tcf_mirred_init()

This one looks ok - and like i mentioned earlier it should be
a patch on its own. Can you please make it a separate patch,
test it and add my signed-off?

> 2. fixed a race condition between __dev_get_by_index() and dev_get()

This one i am not sure. What broke to motivate the patch?
Also note: if you moved things into _init() I am pretty sure
we have at least rtnl held.

cheers,
jamal



