From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch?: linux-2.5.45/net - __secpath_destroy made net depend
 on ipv4
Date: Fri, 01 Nov 2002 02:56:15 -0800 (PST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021101.025615.57289488.davem@redhat.com>
References: <20021101034500.A484@baldur.yggdrasil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: adam@yggdrasil.com
In-Reply-To: <20021101034500.A484@baldur.yggdrasil.com>
List-Id: netdev.vger.kernel.org

   From: "Adam J. Richter" <adam@yggdrasil.com>
   Date: Fri, 1 Nov 2002 03:45:00 -0800

   	In linux-2.5.45, the core networking code calls
   __secpath_destroy via the static inline routine secpath_put in
   include/net/xfrm.h.

Yes, we are fully aware of this.  It will be fixed in due time,
please use CONFIG_INET=y kernels for the time being.
