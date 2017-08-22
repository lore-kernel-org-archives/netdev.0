From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2] lib/bpf: Don't leak fp in bpf_find_mntpt()
Date: Mon, 21 Aug 2017 17:35:58 -0700
Message-ID: <20170821173558.1af30731@xeon-e3>
References: <20170821144651.5379-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38061 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbdHVAgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:36:05 -0400
Received: by mail-pg0-f48.google.com with SMTP id m133so26546208pga.5
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:36:05 -0700 (PDT)
In-Reply-To: <20170821144651.5379-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 16:46:51 +0200
Phil Sutter <phil@nwl.cc> wrote:

> If fopen() succeeded but len != PATH_MAX, the function leaks the open
> FILE pointer. Fix this by checking len value before calling fopen().
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>


Thanks, Applied
