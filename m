From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 2.6.24-rc8 ppp regression
Date: Wed, 23 Jan 2008 10:53:28 +0000
Message-ID: <20080123105327.GE11436@solarflare.com>
References: <20080123093509.GA4718@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:57007 "EHLO
	rutherford.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbYAWKxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 05:53:34 -0500
Content-Disposition: inline
In-Reply-To: <20080123093509.GA4718@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

maximilian attems wrote:
> 
> when killing a wvdial usb modem session:
> 
> Jan 22 23:23:03 dual pppd[7941]: Terminating on signal 15
> Jan 22 23:23:03 dual pppd[7941]: Connect time 92.2 minutes.
> Jan 22 23:23:03 dual pppd[7941]: Sent 1322316 bytes, received 8587156 bytes.
> Jan 22 23:23:03 dual pppd[7941]: Connection terminated.
> Jan 22 23:23:05 dual kernel: usb 3-2: USB disconnect, address 5
> Jan 22 23:23:05 dual kernel: option 3-2:1.0: device disconnected
> Jan 22 23:23:05 dual kernel: option1 ttyUSB1: GSM modem (1-port) converter now disconnected from ttyUSB1
> Jan 22 23:23:05 dual kernel: option 3-2:1.1: device disconnected
> Jan 22 23:23:13 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
> Jan 22 23:23:44 dual last message repeated 3 times
> Jan 22 23:23:54 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1

This is a known bug which doesn't just affect PPP:
<http://bugzilla.kernel.org/show_bug.cgi?id=9778>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
