From: Linhaifeng <haifeng.lin@huawei.com>
Subject: virtio-net: why not always to set avail->flags to VRING_AVAIL_F_NO_INTERRUPT
Date: Wed, 3 Jun 2015 14:32:39 +0800
Message-ID: <556E9F87.7030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <virtualization@lists.linux-foundation.org>,
	"rusty@rustcorp.com.au >> Rusty Russell" <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:48828 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbFCGe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 02:34:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm a newbie and have a question about vring_new_virtqueue function.

Why we set avail->flags to VRING_AVAIL_F_NO_INTERRUPT when no callbacks?
I think we should set avail->flags to VRING_AVAIL_F_NO_INTERRUPT even if no callbacks.
