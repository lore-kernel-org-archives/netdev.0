From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Wed, 13 Jun 2007 23:18:59 +0200
Message-ID: <20070613211859.GA22521@electric-eye.fr.zoreil.com>
References: <20070613004154.GA4187@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38888 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbXFMVUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 17:20:55 -0400
Content-Disposition: inline
In-Reply-To: <20070613004154.GA4187@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> :
[...]
> I'm seeing something odd with r8169 on FC7: doing a ping -s 1600 alternates 
> between a 1s latency and sub 1ms.  Has anyone else seen anything like this?  
> The system in question is an Asus M2A-VM with an onboard RTL8111 (I think).  
> NAPI doesn't seem to make a difference.  The kernel in question is currently 
> a vanilla 2.6.21.5.  Sub-mtu sized packets behave normally.

Same thing here for my 8168 rev 01 (asrock 945G dvi LOM) with 2.6.22-rc4
and 2.6.22-rc3 + r816x patchkit.

Wonderful.

-- 
Ueimor
