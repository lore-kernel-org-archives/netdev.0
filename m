From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] ss: fix the incorrect value of total UNIX_DIAG_*
 number
Date: Wed, 25 Apr 2012 09:26:45 -0700
Message-ID: <20120425092645.180ac196@nehalam.linuxnetplumber.net>
References: <4F97A484.2040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707Ab2DYQ0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 12:26:48 -0400
In-Reply-To: <4F97A484.2040300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 15:15:16 +0800
Shan Wei <shanwei88@gmail.com> wrote:

> From: Shan Wei <davidshan@tencent.com>
> 
> UNIX_DIAG_MAX is included in enum type.
> It is equal to the total number of enum element.
> 
> But lots of enum MAX value is defined as the max enum element, e.g. INET_DIAG_MAX, XFRMA_MAX. 
> The right fixing way seems to define UNIX_DIAG_MAX as UNIX_DIAG_MEMINFO,
> but this way will break other user application.
> 
> So, just fix it on user application.

Nak, we should fix this in the kernel. It is ridiculous to have
a convention that is true for one route attribute type but not
for all of them.
