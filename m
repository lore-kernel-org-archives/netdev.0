From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][AX25]: Potential ax25_uid_assoc-s leaks on module
 unload.
Date: Sat, 12 Apr 2008 18:34:01 -0700 (PDT)
Message-ID: <20080412.183401.80819932.davem@davemloft.net>
References: <4800A598.10506@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
To: xemul@openvz.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4800A598.10506@openvz.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 12 Apr 2008 16:05:44 +0400

> The ax25_uid_free call walks the ax25_uid_list and releases
> entries from it. The problem is that after the fisrt call to
> hlist_del_init the hlist_for_each_entry (which hides behind
> the ax25_uid_for_each) will consider the current position to
> be the last and will return.
> 
> Thus, the whole list will be left not freed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
