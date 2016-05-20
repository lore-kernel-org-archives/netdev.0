From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: ch9200: use kmemdup
Date: Fri, 20 May 2016 19:50:57 -0400 (EDT)
Message-ID: <20160520.195057.1961722108962914882.davem@davemloft.net>
References: <1463666221-16631-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mjg59@srcf.ucam.org,
	tklauser@distanz.ch, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463666221-16631-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Thu, 19 May 2016 19:26:50 +0530

> Use kmemdup when some other buffer is immediately copied into allocated
> region. It replaces call to allocation followed by memcpy, by a single
> call to kmemdup.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Applied.
