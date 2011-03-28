From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Sun, 27 Mar 2011 17:59:22 -0700 (PDT)
Message-ID: <20110327.175922.104040703.davem@davemloft.net>
References: <1300603423.1869.18.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1BAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:00:00 -0400
In-Reply-To: <1300603423.1869.18.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Sun, 20 Mar 2011 02:43:43 -0400

> When parsing the FAC_NATIONAL_DIGIS facilities field, it's possible for
> a remote host to provide more digipeaters than expected, resulting in
> heap corruption.  Check against ROSE_MAX_DIGIS to prevent overflows, and
> abort facilities parsing on failure.
> 
> Additionally, when parsing the FAC_CCITT_DEST_NSAP and
> FAC_CCITT_SRC_NSAP facilities fields, a remote host can provide a length
> of less than 10, resulting in an underflow in a memcpy size, causing a
> kernel panic due to massive heap corruption.  A length of greater than
> 20 results in a stack overflow of the callsign array.  Abort facilities
> parsing on these invalid length values.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable@kernel.org

Applied.
