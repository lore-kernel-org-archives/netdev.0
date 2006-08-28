From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][SCTP]: Fix sctp_primitive_ABORT() call in
 sctp_close()
Date: Mon, 28 Aug 2006 13:50:53 -0700 (PDT)
Message-ID: <20060828.135053.98859723.davem@davemloft.net>
References: <1156792296.11959.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6891
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932103AbWH1Uus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:50:48 -0400
To: sri@us.ibm.com
In-Reply-To: <1156792296.11959.20.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 28 Aug 2006 12:11:36 -0700

> The recent SCTP CVE fix that went into 2.6.18 changed 
> sctp_primitive_ABORT() callers to create an ABORT chunk
> and pass it as an arg instead of struct msghdr.
> While submitting this fix, i missed the other location in
> sctp_close() where this is called.
> 
> Please apply this patch to 2.6.18 and it should also go
> into the stable series.

This shows why embargoes are detrimental to Linux kernel development.

There might have been a chance of this being caught earlier if the
original bug fix had been posted for review here on netdev.  Now we
have the situation where a -stable kernel release went out with the
bogus version of the fix because it got _ZERO_ public review, and it
is likely that several distributions have therefore shipped kernels
with this problem too.

This is unacceptable.

Please everyone, learn from this, and understand that I will always
ignore embargoed bug reports sent to me.  Discuss networking bugs,
no matter how severe, here on netdev from the beginning so we can
fix things correctly and not via some private group of individuals.

Thanks.
