From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.22: ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
Date: Tue, 19 Jun 2007 13:10:21 -0700
Message-ID: <20070619131021.1c814098@localhost.localdomain>
References: <20070619190253.GA19419@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37357 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933837AbXFSUK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 16:10:27 -0400
In-Reply-To: <20070619190253.GA19419@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jun 2007 21:02:53 +0200
Olaf Hering <olaf@aepfle.de> wrote:

> 
> What happend to __ucmpdi2 from David Woodhouse?
> google has a few hits about stuff like this on 32bit powerpc with gcc 4.1.2:
> 
> ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
> 
> using the drivers/net/s2io* files from 2.6.21 with 2.6.22-rc5 fixes the
> compile.
> 
> 25805dcf9d83098cf5492117ad2669cd14cc9b24 adds two u64 >>= 48 followed by
> a switch statement (line 2889 and 6816).

Probably the "switch(err) {" needs a cast to a smaller type (like u8).
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
