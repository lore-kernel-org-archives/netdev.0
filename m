From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: core: fix unused variable sparse warning
Date: Fri, 7 Dec 2012 02:26:39 +0000 (UTC)
Message-ID: <k9rk4v$icm$1@ger.gmane.org>
References: <1354838913-20084-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Dec 2012 at 00:06 GMT, Cong Ding <dinggnu@gmail.com> wrote:
> the variables zero and unres_qlen_max are only used when CONFIG_SYSCTL is
> defined, otherwise it causes the following sparse warning when we turn on
> CONFIG_SYSCTL.
>

commit b93196dc5af7729ff7cc50d3d322ab1a364aa14f
Author: Cong Wang <amwang@redhat.com>
Date:   Thu Dec 6 10:04:04 2012 +0800

    net: fix some compiler warning in net/core/neighbour.c
        
    net/core/neighbour.c:65:12: warning: 'zero' defined but
not used [-Wunused-variable]
    net/core/neighbour.c:66:12: warning: 'unres_qlen_max' defined but
not used [-Wunused-variable]
    
    These variables are only used when CONFIG_SYSCTL is defined,
    so move them under #ifdef CONFIG_SYSCTL.
	        
    Reported-by: Fengguang Wu <fengguang.wu@intel.com>
    Signed-off-by: Cong Wang <amwang@redhat.com>
    Acked-by: Shan Wei <davidshan@tencent.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
