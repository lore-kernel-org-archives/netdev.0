From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] Remove duplicated unlikely() in IS_ERR()
Date: Mon, 18 Aug 2008 19:10:21 -0400
Message-ID: <8bd0f97a0808181610x2e5efce0lb00ba5c0cf9e1e9a@mail.gmail.com>
References: <48A52D69.1040501@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	christof.schmitt@de.ibm.com, linux-mtd@lists.infradead.org,
	yoshfuji@linux-ipv6.org
To: "Hirofumi Nakagawa" <hnakagawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.246]:22966 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbYHRXKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 19:10:23 -0400
Received: by hs-out-0708.google.com with SMTP id 4so667592hsl.5
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 16:10:21 -0700 (PDT)
In-Reply-To: <48A52D69.1040501@miraclelinux.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 3:16 AM, Hirofumi Nakagawa wrote:
> Some drivers have duplicated unlikely() macros.
> IS_ERR() already has unlikely() in itself.
> This patch cleans up such pointless codes although there is no real
> effect on the kernel's behaviour.

sounds like a good check to add to checkpatch.pl ...
-mike
