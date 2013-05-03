From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: Fix crash on receiving VLAN frames
Date: Fri, 3 May 2013 07:59:16 -0700
Message-ID: <20130503075916.21a59491@nehalam.linuxnetplumber.net>
References: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Mirko Lindner <mlindner@marvell.com>
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:46938 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758413Ab3ECO7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:59:33 -0400
Received: by mail-pb0-f50.google.com with SMTP id um15so942235pbc.9
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 07:59:33 -0700 (PDT)
In-Reply-To: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  3 May 2013 18:22:04 +0400
Kirill Smelkov <kirr@mns.spb.ru> wrote:

> Stephen, I wonder, why copy_skb_header() is not used in
> sky2.c::receive_copy() ? Problems, where receive_copy was updated field
> by field showed several times already, e.g.

The drive pre-dates copy_skb_header.
Why not convert driver to use it and avoid this and related problems?
