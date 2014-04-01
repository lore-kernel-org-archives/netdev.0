From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: fix handling of the inner 8021Q tagged
 frame
Date: Mon, 31 Mar 2014 17:45:13 -0700
Message-ID: <20140331174513.0613ac52@nehalam.linuxnetplumber.net>
References: <87a9c6g8l2.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39307 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaDAApQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 20:45:16 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so8970608pab.36
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 17:45:16 -0700 (PDT)
In-Reply-To: <87a9c6g8l2.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Mar 2014 15:56:09 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> +static u32 vxlan_key_hash(const struct vxlan_key *key)
>  {
> -	u64 value = get_unaligned((u64 *)addr);

Assuming structures with only char's is 64 bit aligned is probably
not safe on all architectures.
