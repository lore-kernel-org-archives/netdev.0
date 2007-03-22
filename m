From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BRIDGE]: Fix fdb RCU race
Date: Thu, 22 Mar 2007 11:31:57 -0700
Message-ID: <20070322113157.3fdc7844@freekitty>
References: <4602CAF5.609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44929 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964863AbXCVScH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:32:07 -0400
In-Reply-To: <4602CAF5.609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2007 19:29:09 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Fix what looks like a RCU race. Untested since this is only
> used by ATM, which I don't have.
> 

That looks right, I wonder if the ATM hooks ever get used?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
