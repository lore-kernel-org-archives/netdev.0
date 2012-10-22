From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Mon, 22 Oct 2012 10:46:50 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD6E6@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
 <20121018025508.GD2867@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:54783 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653Ab2JVKqy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:46:54 -0400
In-Reply-To: <20121018025508.GD2867@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, October 18, 2012 8:25 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type
> from skb
> 
> On Wed, Oct 17, 2012 at 04:15:16AM +0530, Mugunthan V N wrote:
> > Cc: Richard Cochran <richardcochran@gmail.com>
> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> > ---
> >  include/linux/ptp_classify.h |   42
> ++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 42 insertions(+), 0 deletions(-)
> 
> Sorry, but nak on this one. It is a bit way too long for a static
> inline. Also, this driver-specific code, and it doesn't belong here.
> 

Yeah agreed on static function too long, but this can be kept inside PTP
frame work as every driver needs to use this API to parse the PTP events
from the skb.

Regards
Mugunthan V N
