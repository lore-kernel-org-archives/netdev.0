From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] bpf: Make bytecode-file reading a little more
 robust
Date: Thu, 3 Aug 2017 15:59:42 -0700
Message-ID: <20170803155942.4112575c@xeon-e3>
References: <20170802125756.26210-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33127 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCW7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:59:45 -0400
Received: by mail-pg0-f42.google.com with SMTP id u5so498726pgn.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 15:59:45 -0700 (PDT)
In-Reply-To: <20170802125756.26210-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Aug 2017 14:57:56 +0200
Phil Sutter <phil@nwl.cc> wrote:

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

Looks good applied.
