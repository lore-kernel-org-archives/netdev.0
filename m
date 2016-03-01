From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 0/8] cls_flower hardware offload support
Date: Tue, 01 Mar 2016 09:18:10 -0800
Message-ID: <56D5CED2.4080708@gmail.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36509 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcCARSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:18:25 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so115367369pab.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 09:18:24 -0800 (PST)
In-Reply-To: <1456842290-7844-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-01 06:24 AM, Amir Vadai wrote:
> Hi,
> 
> This patchset introduces cls_flower hardware offload support over ConnectX-4
> driver, more hardware vendors are welcome to use it too.
> 
> This patchset is based on John's infrastructure for tc offloading [2] to add
> hardware offload support to the flower filter. It also extends the support to
> an additional tc action - skbedit mark operation.
> NIC driver that was used is ConnectX-4. Feature is off by default and could be
> turned on using ethtool.
> 
> Some commands to use this code:
> 

This series depends on these patches still under review,

https://patchwork.ozlabs.org/patch/589150/
https://patchwork.ozlabs.org/patch/589151/
https://patchwork.ozlabs.org/patch/589152/

Just a heads up for DaveM there is an ordering requirement here.

Thanks,
John
