From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: restore rcv_wscale in a repair mode
Date: Mon, 17 Sep 2012 13:25:21 -0400 (EDT)
Message-ID: <20120917.132521.2171143815764276535.davem@davemloft.net>
References: <1347571687-3539973-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xemul@parallels.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347571687-3539973-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Vagin <avagin@openvz.org>
Date: Fri, 14 Sep 2012 01:28:07 +0400

> This patch doesn't break a backward compatibility.
> If someone uses it in a old scheme, a rcv window
> will be restored with the same bug (rcv_wscale = 0).

The whole world is not little-endian.  This does in fact break
backwards compatability.

You will need to extend this in a more reasonable manner.
