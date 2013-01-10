From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/2] bnx2x: bug fix patch series
Date: Thu, 10 Jan 2013 16:53:38 +0200
Message-ID: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3157 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab3AJPvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 10:51:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains 2 bug fixes:

  1. Failed memory allocation during Tx queue allocation can
     later cause the driver to dereference incorrect pointers,
     causing a panic.

  2. During probe, management traffic is stopped and resumes
     only after some of its functions gets loaded.

Please consider applying this patch-series to 'net'.

Thanks,
Yuval Mintz
