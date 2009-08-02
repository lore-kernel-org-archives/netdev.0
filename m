From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: remove superfluous NULL pointer check in
 pcnet32_probe1()
Date: Sun, 02 Aug 2009 12:30:22 -0700 (PDT)
Message-ID: <20090802.123022.148176905.davem@davemloft.net>
References: <200907302319.18150.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, error27@gmail.com, corbet@lwn.net,
	eteo@redhat.com, julia@diku.dk
To: bzolnier@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753446AbZHBTaQ@vger.kernel.org>
In-Reply-To: <200907302319.18150.bzolnier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Thu, 30 Jul 2009 23:19:17 +0200

> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Subject: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
> 
> Move the debug printk() into the proper place and remove superfluous
> NULL pointer check in pcnet32_probe1().
> 
> This takes care of the following entry from Dan's list:
> 
> drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>

Applied, but please CC: netdev@vger.kernel.org for all future
network driver patches so that it gets properly tracked in
patchwork.  Thanks!
