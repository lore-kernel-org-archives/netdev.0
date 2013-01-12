From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next] gianfar: use more portable i/o accessors
Date: Sat, 12 Jan 2013 16:57:48 +0100
Message-ID: <20130112155748.GA2286@netboy.at.omicron.at>
References: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
 <6AE080B68D46FC4BA2D2769E68D765B70820D753@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phillips Kim-R1AAHA <R1AAHA@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:41984 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3ALP57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 10:57:59 -0500
Received: by mail-bk0-f49.google.com with SMTP id jm19so1359889bkc.22
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 07:57:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6AE080B68D46FC4BA2D2769E68D765B70820D753@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 12, 2013 at 01:44:43PM +0000, Tabi Timur-B04825 wrote:
> 
> Can't we just get rid of these functions altogether?

Since they are already in place, I would leave them there. Watching
the kernel development over time, every few years these IO access
idioms tend to change form, and having helper functions avoids huge
change sets when updating.

> Or at least, get
> rid of the local variable?

Okay, sure.

Thanks,
Richard
