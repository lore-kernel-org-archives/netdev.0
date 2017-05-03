From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3] iov_iter: don't revert iov buffer if csum error
Date: Wed, 3 May 2017 08:07:26 +0100
Message-ID: <20170503070726.GG29622@ZenIV.linux.org.uk>
References: <12d4d81f-40c7-c83d-11d6-290acc084695@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pabeni@redhat.com,
        edumazet@google.com, hannes@stressinduktion.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39776 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdECHHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 03:07:40 -0400
Content-Disposition: inline
In-Reply-To: <12d4d81f-40c7-c83d-11d6-290acc084695@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 03:02:32PM +0800, Ding Tianhong wrote:
> The patch 327868212381 (make skb_copy_datagram_msg() et.al. preserve
> ->msg_iter on error) will revert the iov buffer if copy to iter
> failed, but it didn't copy any datagram if the skb_checksum_complete
> error, so no need to revert any data at this place.

See a6a5993243550b09f620941dea741b7421fdf79c in mainline...
