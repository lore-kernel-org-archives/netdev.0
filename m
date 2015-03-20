From: Linhaifeng <haifeng.lin@huawei.com>
Subject: Re: virtio-net: tx queue was stopped
Date: Fri, 20 Mar 2015 17:23:17 +0800
Message-ID: <550BE705.4050806@huawei.com>
References: <55052BB3.2080705@huawei.com> <20150315080138-mutt-send-email-mst@redhat.com> <5506A137.8050909@huawei.com> <20150316132309-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, lilijun <jerry.lilijun@huawei.com>,
	"liuyongan@huawei.com" <liuyongan@huawei.com>,
	"lixiao (H)" <lixiao91@huawei.com>,
	<virtualization@lists.linux-foundation.org>,
	"Rusty Russell" <rusty@rustcorp.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:37881 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbCTJcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 05:32:10 -0400
In-Reply-To: <20150316132309-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2015/3/16 20:26, Michael S. Tsirkin wrote:
> Host just needs to be spec-compliant.
> It must send interrupts unless they are disabled.
> So this sounds like a VHOST_F_FIX_A_BUG to me. Just fix races in
> vhost-user code, and no need for extra flags.

Michael,

Thank you for your suggestion.
I will fix races in vhost-user's code.

-- 
Regards,
Haifeng
