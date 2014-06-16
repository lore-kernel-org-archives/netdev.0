From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Missing return check against Null for return value of
 netdev_alloc_dev_skb()
Date: Mon, 16 Jun 2014 17:32:25 +0400
Message-ID: <539EF1E9.8070607@cogentembedded.com>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>	<20140614.235300.1228145928404410306.davem@davemloft.net> <CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nick Krause <xerofoify@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/16/2014 12:27 AM, Nick Krause wrote:

>  From 62b0d77a1430f74b7f5c008c5e8bec11604b33b0 Mon Sep 17 00:00:00 2001
> From: Nick <xerofoify@gmail.com>
> Date: Sun, 15 Jun 2014 16:16:14 -0400
> Subject: [PATCHv2] Fixes return logic of function of pch_gbe_alloc_tx_buffers()
> Here is the fixed patch changed return type of function to int in
> order to use return -ENOMEM as with the function above it , seems to
> fit , otherwise returns 0.
>   Report if it breaks anything related to this driver.
> Signed-off-by: Nick <xerofoify@gmail.com>

    You should specify your full name in the "Signed-off:" line.

WBR, Sergei
