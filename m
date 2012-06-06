From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_gso_segment oops
Date: Wed, 06 Jun 2012 06:41:33 +0200
Message-ID: <1338957693.2760.3657.camel@edumazet-glaptop>
References: <4FCEC21F.257F91.32344@m12-16.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: kendo <kendo999@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:61302 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab2FFEll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 00:41:41 -0400
Received: by wgbdr13 with SMTP id dr13so5800635wgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 21:41:39 -0700 (PDT)
In-Reply-To: <4FCEC21F.257F91.32344@m12-16.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 10:36 +0800, kendo wrote:
> Hello!
> 
> I use Intel 82574L network, open the GSO/SG/RX Checksum/txchecksum
> support, but the system may occasionally occur caused by
> skb_gso_segment Oops, this was where do I configure error, kernel Bug
> is this? (In fact, using the igb also met once)

New kernels have debugging facility to better diagnose what its going
on. (gso_size, gso_type)

Please upgrade your kernel.
