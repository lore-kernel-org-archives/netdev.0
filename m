From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v1 1/4] net: ti: netcp: restore get/set_pad_info() functionality
Date: Fri, 19 Feb 2016 21:59:05 +0100
Message-ID: <3483781.SODp7Sjq4b@wuerfel>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com> <7111317.k6f7A38a4k@wuerfel> <56C75897.5080103@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C75897.5080103@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 13:01:59 Murali Karicheri wrote:
> > 
> I have just send v2. I will investigate your original patch that added
> regression this afternoon and respond with my observation as soon as
> my investigation is complete.

Thanks.

> I assume, you are trying to make the change
> such that the virtual pointers stored in sw_data/pad works across
> 32bit and 64bit machine, right? 

Yes, that was the idea. The way I intended it, pointers were supposed
to always get stored in a pair of swdata fields and take up 64 bits,
independent of the architecture.

	Arnd
