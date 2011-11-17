From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 17:21:32 -0800
Message-ID: <1321492892.9114.22.camel@nseg_linux_HP1.broadcom.com>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
 <1321490078.2709.86.camel@bwh-desktop>
 <20111117011604.GA8683@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3530 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905Ab1KQBc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 20:32:29 -0500
In-Reply-To: <20111117011604.GA8683@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
> > Finally, do these need to be inline?
> 
> I don't have a strong preference here either.  Phy code tends to be
> slower, so there isn't really a strong performance argument.  The
> implementations don't seem to be so large to argue against it though.
> Would you prefer they not be inlined?
> 

Since we are defining these in .h file, they need to be inline, right?
Otherwise multiple source files including the same .h file will have
conflict.
