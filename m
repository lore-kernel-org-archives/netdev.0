From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 v2] dl2k: Handle memory allocation errors in
 alloc_list
Date: Fri, 20 Nov 2015 14:48:59 -0500 (EST)
Message-ID: <20151120.144859.248502507361985820.davem@davemloft.net>
References: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Thu, 19 Nov 2015 20:13:04 +0100

> If memory allocation fails in alloc_list(), free the already allocated
> memory and return -ENOMEM. In rio_open(), call alloc_list() first and
> abort if it fails. Move HW access (set RFDListPtr) out ot alloc_list().
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied to net-next.
