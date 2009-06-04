From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] cxgb3: Add Aeluros 2020 phy support
Date: Wed, 03 Jun 2009 20:00:50 -0700 (PDT)
Message-ID: <20090603.200050.146284422.davem@davemloft.net>
References: <20090529075829.30669.41488.stgit@speedy5>
	<20090601105349.GF3051@decadent.org.uk>
	<4A27311D.7070400@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756218AbZFDDBF@vger.kernel.org>
In-Reply-To: <4A27311D.7070400@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 03 Jun 2009 19:27:41 -0700

> In a boot over the network environment, request_firmware() will not be
> granted
> access to the file system.

This is not true, first of all.  It can be built into the kernel image
via CONFIG_FIRMWARE_IN_KERNEL.

Second of all, there is initrd.

There are NO EXCUSES for not using request_firmware() at this point.
