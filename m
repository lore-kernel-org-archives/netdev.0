From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 4/8] e1000e: Out of line __ew32_prepare/__ew32
Date: Fri, 16 May 2014 20:23:41 -0700
Message-ID: <20140516202341.4b402aa6@nehalam.linuxnetplumber.net>
References: <1400276595-6965-1-git-send-email-andi@firstfloor.org>
	<1400276595-6965-5-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Andi Kleen <ak@linux.intel.com>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:59200 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbaEQDXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 23:23:44 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so3390218pbb.20
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 20:23:44 -0700 (PDT)
In-Reply-To: <1400276595-6965-5-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2014 14:43:11 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Out of lining these two common inlines saves about 30k text size,
> due to their errata workarounds.
> 
> 14131431	2008136	1507328	17646895	10d452f	vmlinux-before-e1000e
> 14101415	2004040	1507328	17612783	10cbfef	vmlinux-e1000e
> 
> Cc: jeffrey.t.kirsher@intel.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Since you are making a formerly private function global, the name
should be unique. I.e prefix it with e1000_
