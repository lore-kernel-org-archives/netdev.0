From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix assignment of signed expression to unsigned
 variable
Date: Sat, 23 Mar 2013 19:56:51 -0400 (EDT)
Message-ID: <20130323.195651.2270136988020869155.davem@davemloft.net>
References: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: gmate.amit@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kumar Amit Mehta <gmate.amit@gmail.com>
Date: Sat, 23 Mar 2013 11:52:55 -0700

> fix for incorrect assignment of signed expression to unsigned variable.
> 
> Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>

Returning positive error codes is just as broken as what is there
currently.

These routines should return 0 or 1, the return value isn't even used
in any way, it is just tested against zero.
