From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [Question] e1000: e1000_adapter->polling_netdev is useless
Date: Tue, 02 Dec 2008 21:33:09 +0800
Message-ID: <49353915.4060002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50743 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752146AbYLBNdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 08:33:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000_adapter->polling_netdev is not actually used after allocated.
So, my question is that is it useless?


