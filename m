From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH] bpf: Make bytecode-file reading a little more
 robust
Date: Wed, 02 Aug 2017 21:21:30 +0200
Message-ID: <5982263A.9000604@iogearbox.net>
References: <20170802125756.26210-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59914 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdHBTVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 15:21:33 -0400
In-Reply-To: <20170802125756.26210-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 02:57 PM, Phil Sutter wrote:
> bpf_parse_string() will now correctly handle:
>
> - Extraneous whitespace,
> - OPs on multiple lines and
> - overlong file names.
>
> The added feature of allowing to have OPs on multiple lines (like e.g.
> tcpdump prints them) is rather a side effect of fixing detection of
> malformed bytecode files having random content on a second line, like
> e.g.:
>
> | 4,40 0 0 12,21 0 1 2048,6 0 0 262144,6 0 0 0
> | foobar
>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
