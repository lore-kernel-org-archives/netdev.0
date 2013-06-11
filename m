From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 01/12] vxlan: fix crash from work pending on
 module removal
Date: Tue, 11 Jun 2013 02:00:19 +0000 (UTC)
Message-ID: <kp60bj$rn$1@ger.gmane.org>
References: <20130610200524.721617349@vyatta.com>
 <20130610132458.31aa2386@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60770 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab3FKCAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 22:00:38 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UmDsy-0001A0-HS
	for netdev@vger.kernel.org; Tue, 11 Jun 2013 04:00:36 +0200
Received: from 112.116.154.100 ([112.116.154.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 04:00:36 +0200
Received: from xiyou.wangcong by 112.116.154.100 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 04:00:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jun 2013 at 20:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> Switch to using a per module work queue so that all the socket
> deletion callbacks are done when module is removed.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
