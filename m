From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH wireless-dev] Remove struct pt_regs * from d80211 drivers
Date: Fri, 13 Oct 2006 22:45:34 +0200
Message-ID: <200610132245.34637.IvDoorn@gmail.com>
References: <200610131601.54254.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:54761 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751895AbWJMUqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 16:46:37 -0400
Received: by nf-out-0910.google.com with SMTP id x30so1092950nfb
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 13:46:35 -0700 (PDT)
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200610131601.54254.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 October 2006 22:01, Michael Wu wrote:
> Remove struct pt_regs * from d80211 drivers
> 
> This patch will be necessary once wireless-dev pulls the 2.6.19-rc2 changes 
> which include the removal of the struct pt_regs * argument in interrupt 
> handler callbacks. Thanks to Johannes Berg <johannes@sipsolutions.net> for 
> finding a spot in the bcm43xx driver that called the irq handler manually.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>

Patch looks good for rt2x00. :)

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
