From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 0/5] HID: roccat: Achieve userspace notification on sysfs
 attribute creation
Date: Thu, 9 Dec 2010 14:30:40 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012091430130.508@pobox.suse.cz>
References: <1290801444.18750.161.camel@neuromancer>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: Stefan Achatz <erazor_de@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60062 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab0LINan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 08:30:43 -0500
In-Reply-To: <1290801444.18750.161.camel@neuromancer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Nov 2010, Stefan Achatz wrote:

> Adding sysfs attributes to an already created device raises no userland
> notification.
> 
> Instead of fiddling around in the depths of busses and devices I reuse the
> event char device (module hid-roccat). This device gets now created with
> a hardware specific class that contains the device attributes.

Hi Stefan,

I have applied the series, and removed the #pragma pack ugliness. Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
