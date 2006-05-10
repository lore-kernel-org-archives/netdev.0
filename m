From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 15:55:59 +0200
Message-ID: <20060510155559.6875b58d@griffin.suse.cz>
References: <200605061401.01795.IvDoorn@gmail.com>
	<200605100001.20180.IvDoorn@gmail.com>
	<200605091836.10138.flamingice@sourmilk.net>
	<200605101537.15213.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44469 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964965AbWEJN4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 09:56:02 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605101537.15213.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006 15:37:11 +0200, Ivo van Doorn wrote:
> True, I agree here. But when rt2x00 was using the ipw stack a much
> requested feature from users was to be able to perform scanning while
> interface was down. (The requests did not specify if it they wanted passive or active scanning)
> But the reason for these requests was that some user space applications and/or
> distribution network scripts relied on the fact that the driver was capable of scanning
> while the interface was down, so the interface would only be brought up at boot time,
> when there was no desired AP in the scan result.

Such applications and scripts are broken. Let your users fill bug
reports to their distribution bugzillas.

> I don't know which distributions or user space application these were, but due to the amount
> of these requests it had been considered an important feature.

I wouldn't consider breaking the way the whole Linux networking works as
a feature.

 Jiri

-- 
Jiri Benc
SUSE Labs
