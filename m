From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] net/ipv4/ipmr.c fixes
Date: Wed, 7 Jul 2004 14:09:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707140945.07c88057.davem@redhat.com>
References: <877jtfmxg9.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <877jtfmxg9.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 08 Jul 2004 04:25:26 +0900
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:

> - pim_protocol warning fix
> 
> - ipmr_vif_open() and ipmr_mfc_open() allocates the memory, so it
>   should use seq_release_private().
> 
> - ipmr_mfc_seq_xxx is using it->cache, in order to control whether
>   unlock should be do or not, but it->cache was not initialized in
>   ipmr_mfc_seq_start(). So it can point the previous state if user
>   did seek(). This become to the cause of twice unlock.

Looks good, patch applied.  Thanks!
