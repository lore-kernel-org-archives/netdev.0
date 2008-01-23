From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.24-rc8 ppp regression
Date: Wed, 23 Jan 2008 14:33:31 +0300
Message-ID: <20080123113331.GA8749@2ka.mipt.ru>
References: <20080123093509.GA4718@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34844 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbYAWLeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 06:34:00 -0500
Content-Disposition: inline
In-Reply-To: <20080123093509.GA4718@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2008 at 10:35:09AM +0100, maximilian attems (max@stro.at) wrote:
> Jan 22 23:23:13 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
> Jan 22 23:23:44 dual last message repeated 3 times
> Jan 22 23:23:54 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
> 
> 2.6.24-rc7 works fine, not yet bisected, will do later in the evening.

Fix (revert) is in Dave's tree already.

-- 
	Evgeniy Polyakov
