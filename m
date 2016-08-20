From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vmxnet3: fix tx data ring copy for variable size
Date: Fri, 19 Aug 2016 22:44:53 -0700 (PDT)
Message-ID: <20160819.224453.463393161743242538.davem@davemloft.net>
References: <1471628022-93931-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        pv-drivers@vmware.com, gyang@vmware.com
To: skhare@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471628022-93931-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shrikrishna Khare <skhare@vmware.com>
Date: Fri, 19 Aug 2016 10:33:42 -0700

> 'Commit 3c8b3efc061a ("vmxnet3: allow variable length transmit data ring
> buffer")' changed the size of the buffers in the tx data ring from a
> fixed size of 128 bytes to a variable size.
> 
> However, while copying data to the data ring, vmxnet3_copy_hdr continues
> to carry the old code that assumes fixed buffer size of 128. This patch
> fixes it by adding correct offset based on the actual data ring buffer
> size.
> 
> Signed-off-by: Guolin Yang <gyang@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

Applied.
