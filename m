From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [DSCAPE] rate_control needs some form of reference counting
Date: Tue, 1 Aug 2006 18:04:30 +0200
Message-ID: <20060801180430.652e2c64@griffin.suse.cz>
References: <20060729215645.GE1464@riddly.domek.prywatny>
	<20060801161023.1e66d844@griffin.suse.cz>
	<20060801151632.GA1754@riddly.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:23442 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932402AbWHAQEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 12:04:32 -0400
To: Karol Lewandowski <kl@jasmine.eu.org>
In-Reply-To: <20060801151632.GA1754@riddly.domek.prywatny>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006 17:16:32 +0200, Karol Lewandowski wrote:
> Without that ieee80211_register_hw was returning value from previous
> check:

I missed that. Thanks for spotting this.

> This fixes that oops.  Problem remains, though.  I suppose that oops
> would happen anyway if someone would do:
> 
>   # modprobe rate_control   # loads 80211
>   # modprobe rt2500pci
> 
> (Driver needs to initialize cleanly here, mine has some (different)
> problem so I'm just guessing here...)
> 
>  # rmmod rate_control
> 
> <oops here>, I think.

This is the reason I wrote it's not easy to fix.

But your patch is correct and will be applied, thanks.

 Jiri

-- 
Jiri Benc
SUSE Labs
