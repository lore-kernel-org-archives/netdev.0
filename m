From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: Reproducible corruption with SG offloading
Date: Wed, 13 Jan 2010 14:00:30 -0800
Message-ID: <20100113220030.GA15240@xw6200.broadcom.net>
References: <4B4B181B.3020208@rabbit.us>
 <20100113205531.GA15115@xw6200.broadcom.net> <4B4E3F1B.3000807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Peter Rabbitson" <rabbit+list@rabbit.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2985 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756443Ab0AMWA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 17:00:56 -0500
In-Reply-To: <4B4E3F1B.3000807@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 01:46:03PM -0800, Rick Jones wrote:
> IIRC, long ago and far away the AceNIC had an "issue" crossing 4GB boundaries - 
> did that carry-over into the 5701?
> 
> rick jones

If it did, there is code in the transmit routine to detect and
workaround that.

