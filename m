From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH RFC 0/2] Add extended pause query capability
Date: Fri, 14 Oct 2011 13:55:42 -0700
Message-ID: <20111014205542.GA9707@mcarlson.broadcom.com>
References: <1318625642-9668-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2508 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932460Ab1JNUzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 16:55:35 -0400
In-Reply-To: <1318625642-9668-1-git-send-email-mcarlson@broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2011 at 01:54:00PM -0700, Matt Carlson wrote:
> The current implementation of get_pauseparam allows userspace to query the
> flow control configuration, but not the flow control status.  This patchset
> defines a new ethtool_pauseparamext structure and adds a new
> get_pauseparamext ethtool callback to support it.  The new facilities allow
> the driver to report both config and status in the same query.
> 
> Please note that Ben Hutchings' suggestion to deduce the flow control settings
> through the 'advertising' and 'lp_advertising' from ETHTOOL_GSET was considered,
> but rejected because there was no way to know if the flow control
> advertisements reported were valid.

Please add the following to the patches.  Sorry Michael.

Signed-off-by: Michael Chan <mchan@broadcom.com>
