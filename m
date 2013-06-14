From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: mlx4_core 0000:05:00.0: event 19 arrived
Date: Fri, 14 Jun 2013 11:10:03 -0500
Message-ID: <20130614161003.GB7310@sbohrermbp13-local.rgmadvisors.com>
References: <20130614155342.GA7310@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ogerlitz@mellanox.com, amirv@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:44644 "EHLO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502Ab3FNQSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 12:18:01 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so911074oag.6
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 09:18:00 -0700 (PDT)
In-Reply-To: <20130614155342.GA7310@sbohrermbp13-local.rgmadvisors.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 10:53:42AM -0500, Shawn Bohrer wrote:
> I've been testing 3.10-rc5, and while I'm not sure what exactly I was
> running at the time or if there were any negative effects, but I just
> noticed my dmesg buffer is completely full of the following messages:
> 
> ...
> [137475.687703] mlx4_core 0000:05:00.0: event 19 arrived
> [137475.688944] mlx4_core 0000:05:00.0: event 19 arrived
> [137475.689673] mlx4_core 0000:05:00.0: event 19 arrived
> [137475.697600] mlx4_core 0000:05:00.0: event 19 arrived
> [137475.699125] mlx4_core 0000:05:00.0: event 19 arrived
> ...
> 
> This appears to come from drivers/net/ethernet/mellanox/mlx4/eq.c:473
> 
> $ ethtool -i eth4
> driver: mlx4_en
> version: 2.0 (Dec 2011)
> firmware-version: 2.11.500
> bus-info: 0000:05:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: no
> supports-register-dump: no
> 
> I'll see if I can figure out a workload that reproduced the message
> later today, but perhaps the message is enough to get some ideas from
> the Mellanox folks.

I also just remembered that I had set debug_level=1 on mlx4_core and
that is likely why I am now seeing these messages.  If these messages
are expected and harmless then I'll simply turn off the debug
messages.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
