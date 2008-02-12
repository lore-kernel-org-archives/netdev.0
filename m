From: Johan Andersson <johan.andersson@transmode.se>
Subject: Re: e1000e hardware CRC stripping breaks bridging
Date: Tue, 12 Feb 2008 14:57:50 +0100
Message-ID: <1202824670.26114.20.camel@gentoo-johan.transmode.se>
References: <47B19EDE.5020802@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:38370 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758010AbYBLN5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 08:57:53 -0500
In-Reply-To: <47B19EDE.5020802@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the bug report:
http://bugzilla.kernel.org/show_bug.cgi?id=9940

/Johan

On Tue, 2008-02-12 at 13:27 +0000, Daniel Drake wrote:
> Hi,
> 
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
> 
> Thanks,
> Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

