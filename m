From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: question about eth_header
Date: Tue, 20 Nov 2012 15:44:04 +0200
Message-ID: <1353419044.16036.6.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1230 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab2KTNqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 08:46:14 -0500
Received: from [10.185.7.55] (lb-tlvb-dmitry.il.broadcom.com
 [10.185.7.55]) by mail-irva-13.broadcom.com (Postfix) with ESMTP id
 BDC6C40FE3 for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 05:43:58
 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to use eth_hdr() but it looks like it doesn't point to mac
header (mac header is present at skb->data). Shouldn't
skb_reset_mac_header() be called inside eth_header()?

Thanks.
