From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Thu, 22 May 2008 16:52:36 +0100
Message-ID: <20080522155234.GX28241@solarflare.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-4-git-send-email-mchan@broadcom.com> <20080522151540.GA27897@mars.virtualiron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, anilgv@broadcom.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Konrad Rzeszutek <konrad@virtualiron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:41631 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753302AbYEVPxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 11:53:14 -0400
Content-Disposition: inline
In-Reply-To: <20080522151540.GA27897@mars.virtualiron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Konrad Rzeszutek wrote:
> > + * bnx2i_iscsi_license_error - displays iscsi license related error message
> 
> Doesn't look very license related. Just says 'not supported'.

Could be that some hardware strap pin is being used as a dongle.  This
doesn't seem entirely in the spirit of GPL, and would be rather easy to
remove...

> > + * @hba:		adapter instance pointer
> > + * @error_code:		error classification
> > + *
> > + * Puts out an error log when driver is unable to offload iscsi connection
> > + *	due to license restrictions
> 
> Maybe adding in some extra information to the error, such as: "Due to
> GPL restrictions, etc.." .. What does 'LOM' stand for?

LOM is a common abbreviation for "LAN on motherboard" as opposed to an
expansion card.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
