From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix infoleak in llc
Date: Wed, 04 May 2016 16:20:01 -0400 (EDT)
Message-ID: <20160504.162001.386272862604605345.davem@davemloft.net>
References: <1462307705-5882-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu, insu@gatech.edu,
	kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462307705-5882-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kangjie Lu <kangjielu@gmail.com>
Date: Tue,  3 May 2016 16:35:05 -0400

> The stack object “info” has a total size of 12 bytes. Its last byte
> is padding which is not initialized and leaked via “put_cmsg”.
> 
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>

Applied.
