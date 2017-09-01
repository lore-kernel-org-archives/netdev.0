From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 2/6] Convert the obvious cases to strlcpy()
Date: Fri, 01 Sep 2017 21:13:37 +0200
Message-ID: <59A9B161.1030806@iogearbox.net>
References: <20170901165256.21459-1-phil@nwl.cc> <20170901165256.21459-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40586 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbdIATNk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:13:40 -0400
In-Reply-To: <20170901165256.21459-3-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 06:52 PM, Phil Sutter wrote:
> This converts the typical idiom of manually terminating the buffer after
> a call to strncpy().
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

For BPF loader bits:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
