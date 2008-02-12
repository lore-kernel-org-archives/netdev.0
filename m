From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000e hardware CRC stripping breaks bridging
Date: Tue, 12 Feb 2008 09:25:43 -0800
Message-ID: <47B1D697.8030503@intel.com>
References: <47B19EDE.5020802@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johan.andersson@transmode.se,
	dsd@gentoo.org, jesse.brandeburg@intel.com
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11378 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757067AbYBLRa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 12:30:58 -0500
In-Reply-To: <47B19EDE.5020802@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Drake wrote:
> Johan Andersson reported on the Gentoo bugzilla that the hardware CRC
> stripping enabled by e1000e breaks bridging because sometimes the CRC is
> not stripped:
> https://bugs.gentoo.org/show_bug.cgi?id=209235
> 
> Apparently "upstream" are aware but I couldn't find any mails or bug
> reports on this topic.
> 
> What's the current status of this issue? Perhaps we should disable
> hardware CRC stripping for 2.6.24.x/2.6.25 until this gets fixed?

Jesse figured it out. I just send you a patch to test, can you guys give that a
try and see if it fixes the situation? Johan?

thanks,

Auke
