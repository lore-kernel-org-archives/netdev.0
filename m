From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Subject: [PATCH 0/3] netdev: ARRAY_SIZE() cleanups
Date: Thu, 18 Oct 2007 11:47:06 +0200
Message-ID: <20071018094706.GA23058@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:14269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759944AbXJRJnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:43:53 -0400
Received: by ug-out-1314.google.com with SMTP id z38so396542ugc
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 02:43:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

these patches convert more cases of array size calculations to use the
ARRAY_SIZE() macro.

First patch converts those of the form 'sizeof(arr) / ETH_GSTRING_LEN',
second one some other mostly obvious cases, and the third applies to the
almost dead sk98lin driver (which also removes a useless check AFAICS).

Alex

