From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 17/51] lib/bpf: Don't leak fp in bpf_find_mntpt()
Date: Mon, 14 Aug 2017 10:46:18 +0200
Message-ID: <5991635A.4070607@iogearbox.net>
References: <20170812120510.28750-1-phil@nwl.cc> <20170812120510.28750-18-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33855 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752411AbdHNIq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 04:46:29 -0400
In-Reply-To: <20170812120510.28750-18-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2017 02:04 PM, Phil Sutter wrote:
> If fopen() succeeded but len != PATH_MAX, the function leaks the open
> FILE pointer. Fix this by checking len value before calling fopen().
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
