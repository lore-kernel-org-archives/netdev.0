From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6] Reduce code duplication of zerocopy of tun and
 macvtap
Date: Wed, 07 Aug 2013 16:52:57 -0700 (PDT)
Message-ID: <20130807.165257.2178020819318828004.davem@davemloft.net>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue,  6 Aug 2013 17:45:02 +0800

> This series tries to reduce the code duplication of zerocopy of tun and macvtap
> by:
> 
> - Move common helpers iov_pages() and zerocopy_sg_from_iovec() to net/core
> - Use exist helpers instead of open coding the new one
> 
> With this seires, we can do further optimizations on top.

Looks great, applied!
