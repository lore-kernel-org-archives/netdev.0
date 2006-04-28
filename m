From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 29/32] rt2x00: dscape compatibilitiy
Date: Fri, 28 Apr 2006 13:12:37 +0200
Message-ID: <20060428131237.49dbe6a1@griffin.suse.cz>
References: <200604280003.19645.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40861 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965001AbWD1LMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 07:12:39 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604280003.19645.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006 00:03:19 +0200, Ivo van Doorn wrote:
> Latest dscape patches have broken rt2x00,
> fix compile issues, and support the new features.

> @@ -2466,6 +2568,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
>  	hw->no_tkip_wmm_hwaccel = 1;
>  	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
> +	hw->monitor_during_oper = 1;

You should not set this to 1 if you support only one interface at a
time. Please add support for concurrent running of one regular (i.e.
STA, IBSS, AP, WDS) interface plus arbitrary number of monitor
interfaces or set monitor_during_oper to 0.

(Yes, I know, I definitely must reserve some time to write a
documentation about monitor mode support.)

Thanks,

-- 
Jiri Benc
SUSE Labs
