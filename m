From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] iov_iter: don't revert iov buffer if csum error
Date: Sat, 29 Apr 2017 21:48:23 +0100
Message-ID: <20170429204822.GS29622@ZenIV.linux.org.uk>
References: <d1ef9185-0956-aed9-e44b-84458cf28764@huawei.com>
 <20170429024647.GO29622@ZenIV.linux.org.uk>
 <0cc7c1d2-87d0-6cc4-624b-1cf96678bfd7@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pabeni@redhat.com,
        edumazet@google.com, hannes@stressinduktion.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0cc7c1d2-87d0-6cc4-624b-1cf96678bfd7@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 29, 2017 at 05:37:38PM +0800, Ding Tianhong wrote:

> Looks good, if so, we don't need the csum_error any more,

Acked-by: Al Viro <viro@zeniv.linux.org.uk>

Dave, I could put that through my tree, but I think it would be better off
in net.git; either way, it needs to go into mainline before -final...
