From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v5 1/5] tc: m_action: Improve conversion to C99
 style initializers
Date: Wed, 20 Jul 2016 12:15:06 -0700
Message-ID: <20160720121506.1a2ef09a@xeon-e3>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
	<b5628e0db415424485e9cb6975d1f576@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@Brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34468 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbcGTTOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:14:50 -0400
Received: by mail-pf0-f182.google.com with SMTP id p64so21910112pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 12:14:50 -0700 (PDT)
In-Reply-To: <b5628e0db415424485e9cb6975d1f576@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jul 2016 14:48:41 +0000
Phil Sutter <phil@nwl.cc> wrote:

> This improves my initial change in the following points:
> 
> - Flatten embedded struct's initializers.
> - No need to initialize variables to zero as the key feature of C99
>   initializers is to do this implicitly.
> - By relocating the declaration of struct rtattr *tail, it can be
>   initialized at the same time.
> 
> Fixes: a0a73b298a579 ("tc: m_action: Use C99 style initializers for struct req")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Series applied
