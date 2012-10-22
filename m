From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Mon, 22 Oct 2012 12:32:20 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD904@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
 <20121018025508.GD2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD6E6@DBDE01.ent.ti.com>
 <20121022113622.GD2285@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:44404 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069Ab2JVMcZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:32:25 -0400
In-Reply-To: <20121022113622.GD2285@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, October 22, 2012 5:06 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type
> from skb
> 
> On Mon, Oct 22, 2012 at 10:46:50AM +0000, N, Mugunthan V wrote:
> >
> > Yeah agreed on static function too long, but this can be kept inside
> PTP
> > frame work as every driver needs to use this API to parse the PTP
> events
> > from the skb.
> 
> No, not every driver need this code. Otherwise it would already exist
> in every driver.
> 
> Although some of the hardware does provide packet metadata for
> matching time stamps to payloads, each hardware that I know of has its
> own subtle differences in this regard.
> 

Ok, will move this code to CPTS driver itself.

Regards
Mugunthan V N
