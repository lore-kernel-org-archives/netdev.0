From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [d80211 patch 1/1] setting bss freq and phymode using rx_status
Date: Mon, 25 Sep 2006 18:16:43 +0200
Message-ID: <20060925181643.1621489a@griffin.suse.cz>
References: <44F356DF.9000000@linux.intel.com>
	<20060921190126.4d884c44@logostar.upir.cz>
	<1158865436.27546.23.camel@localhost.localdomain>
	<4512EC5C.1030807@linux.intel.com>
	<1158870634.5769.21.camel@localhost.localdomain>
	<4512F876.7000203@linux.intel.com>
	<20060922003844.6817f22b@logostar.upir.cz>
	<20060921225514.GA26850@bougret.hpl.hp.com>
	<20060922004235.GA7322@instant802.com>
	<20060922005743.GB27052@bougret.hpl.hp.com>
	<451463D6.4070309@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41421 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751167AbWIYQQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 12:16:45 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <451463D6.4070309@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 15:29:42 -0700, mabbas wrote:
> -	bss->hw_mode = local->conf.phymode;
> +	bss->hw_mode = rx_status->phymode;
>  	bss->channel = channel;
> -	bss->freq = local->conf.freq;
> +	bss->freq = rx_status->freq;
>  	if (channel != local->conf.channel &&

>  	    (local->conf.phymode == MODE_IEEE80211G ||
>  	     local->conf.phymode == MODE_IEEE80211B) &&

Are you sure you want local->conf.phymode here?

 Jiri

-- 
Jiri Benc
SUSE Labs
