From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: capturing packets with FCS error (tg3)
Date: Fri, 08 Sep 2006 14:24:03 -0700
Message-ID: <1157750643.9584.2.camel@rh4>
References: <582bc1220609081304l2fdf36aaua1e0f0c1ca6ecbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:52238 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751145AbWIHV0D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 17:26:03 -0400
To: "Sabit A. Sayeed" <sabitas@gmail.com>
In-Reply-To: <582bc1220609081304l2fdf36aaua1e0f0c1ca6ecbd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-08 at 16:04 -0400, Sabit A. Sayeed wrote:
> Is it possible to capture packets with FCS error using the tg3 driver?
> 
Yes, you'll need to set the RX_MODE_NO_CRC_CHECK in the MAC_RX_MODE
register.

