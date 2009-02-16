From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: net.ipv6.conf.INT.accept_ra_rt_info_max_plen defaults to 0
Date: Mon, 16 Feb 2009 08:31:34 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0902160827570.28957@netcore.fi>
References: <alpine.LRH.2.00.0902030632240.7583@netcore.fi>  <20090202.213616.258001767.davem@davemloft.net> <b245135e0902150605q1bbaddc3pa3dd6053e158ae2e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Teran McKinney <sega01@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:55132 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029AbZBPGbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 01:31:44 -0500
In-Reply-To: <b245135e0902150605q1bbaddc3pa3dd6053e158ae2e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let me add to what DaveM said:

On Sun, 15 Feb 2009, Teran McKinney wrote:
>> It seems that it is disabled like this by default when
>> accept_ra_rtr_pref is enabled, and that seems pretty reasonable to me.

accept_ra_rtr_pref is about router preferences. 
accept_ra_rt_info_max_plen is about more specific routes.  They are 
defined in the same RFC, and probably many implementers implement them 
at the same time.  However, there is no logical connection between the 
two, and making the default value of one depend on the default value 
of the other doesn't seem to make sense to me.

Even if we didn't enable accept_ra_rt_info_max_plen by default, I 
don't think it should depend on the value of accept_ra_rtr_pref.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
