From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 17:04:24 -0700
Message-ID: <4609B108.7030302@hp.com>
References: <20070327214754.GA11677@dag-work> <20070327.153025.45876618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dagriego@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:58222 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbXC1AEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 20:04:32 -0400
In-Reply-To: <20070327.153025.45876618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> There is no reason for this ioctl at all.  Either existing
> facilities provide what you need or what you want is a
> protocol violation we can't do.

I agree that 99 times out of ten such a mechanism serves only as a 
massive KLUDGE to paper-over application bugs.  I'll also sadly 
point-out that such a mechanism exists in HP-UX 11.X and I suspect 
Solaris !-(  I've spent probably the last decade or so attempting to 
discourage its use in the HP-UX space, but like some daemon from hell it 
just refuses to die.

rick jones
