From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: NET: dmfe.c : fix access to card's pci config space in D3
Date: Fri, 23 Nov 2007 01:29:02 +0200
Message-ID: <200711230129.02570.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:58837 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbXKVX3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 18:29:20 -0500
Received: by nf-out-0910.google.com with SMTP id g13so2585248nfb
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2007 15:29:18 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I somehow assumed that pci_save_state should be called while 
device is powered off, but actually the opposite is true.

Thus I am sending this patch to fix it.

Sorry for this mistake,
	Best regards,
		Maxim Levitsky

