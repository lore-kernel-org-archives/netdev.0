From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.17-rc4: netfilter LOG messages truncated via NETCONSOLE (2)
Date: Fri, 2 Jun 2006 16:02:12 +0200
Message-ID: <20060602140212.GA7881@janus>
References: <20060531094626.GA23156@janus> <447DAEC9.3050003@trash.net> <20060531160611.GA25637@janus> <447DC613.10102@trash.net> <20060531172936.GB25788@janus> <447DD66C.30605@trash.net> <20060601091124.GA31642@janus> <447F2537.1080807@trash.net> <20060602123559.GA7505@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:12160 "EHLO
	janus.localdomain") by vger.kernel.org with ESMTP id S1751152AbWFBOCN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 10:02:13 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20060602123559.GA7505@janus>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 02:35:59PM +0200, me wrote:

[...]

> This is a tcpdump done after rebooting "posio"
> to 2.6.13.2 showing how it should have looked:

[snip]

The 2.6.13.2 data is inconsistent. The bug appears to be present there at
well after closer examination. So there must be another factor involved
because I have at least one case logged where 2.6.13.2 did work (the
"sirkka" log in my previous mail). Applying your patch on 2.6.13.2
again removes the protocol is buggy messages (when doing a tcpdump)
but the problem of the 10 missing packets persists.

-- 
Frank
