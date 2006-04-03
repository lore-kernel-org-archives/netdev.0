From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Kill unused decap state argument
Date: Sun, 02 Apr 2006 23:29:33 -0700 (PDT)
Message-ID: <20060402.232933.01462994.davem@davemloft.net>
References: <200604022014.k32KE6LH011600@hera.kernel.org>
	<20060403043134.GA7173@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751592AbWDCG3v@vger.kernel.org>
To: davej@redhat.com
In-Reply-To: <20060403043134.GA7173@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Sun, 2 Apr 2006 23:31:34 -0500

> This breaks SELinux compilation.
> security/selinux/xfrm.c: In function 'selinux_socket_getpeer_dgram':
> security/selinux/xfrm.c:284: error: 'struct sec_path' has no member named 'x'
> security/selinux/xfrm.c: In function 'selinux_xfrm_sock_rcv_skb':
> security/selinux/xfrm.c:317: error: 'struct sec_path' has no member named 'x'
> 
> Does this look sane ?

Yes it does, thanks Dave.
