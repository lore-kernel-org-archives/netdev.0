From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] SFC: Default to 'n' for Solarflare device.
Date: Tue, 17 Apr 2012 15:18:33 +0100
Message-ID: <1334672313.3209.133.camel@deadeye>
References: <1334647992-6022-1-git-send-email-tm@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Tao Ma <tm@tao.ma>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43821 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751410Ab2DQOSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 10:18:42 -0400
In-Reply-To: <1334647992-6022-1-git-send-email-tm@tao.ma>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 15:33 +0800, Tao Ma wrote:
> From: Tao Ma <boyu.mt@taobao.com>
> 
> We make oldconfig every time when a new kernel arrives, but
> if we don't have such a device(I guess this is the most common
> case for a new device), the default value should be 'n' so
> that the kernel size we build doesn't grow up too much quickly.
> For anyone who has the device, it is OK for them to turn it on
> by themselves. And it goes with these Solarflare devices.
[...]

These are all sub-options of CONFIG_SFC, i.e. if you disable CONFIG_SFC
then they don't appear and if you set CONFIG_SFC=m then they only add
code to the module.

The default of y is correct.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
