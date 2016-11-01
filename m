From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 5/5] lwtunnel: Limit number of recursions on
 output to 5
Date: Tue, 1 Nov 2016 09:09:00 +0100
Message-ID: <20161101080900.GA13415@pox.localdomain>
References: <f3f701803859d5aacff9134026de0ae656ede3a6.1477959702.git.tgraf@suug.ch>
 <201611011209.dx1fkD00%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36876 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1167915AbcKAIJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 04:09:03 -0400
Received: by mail-wm0-f54.google.com with SMTP id t79so92857872wmt.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 01:09:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <201611011209.dx1fkD00%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 at 12:52pm, kbuild test robot wrote:
> Hi Thomas,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Thomas-Graf/bpf-BPF-for-lightweight-tunnel-encapsulation/20161101-084038
> config: arm64-allmodconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm64 
> 
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `bpf_output':
> >> ncsi-manage.c:(.text+0x8e9f4): undefined reference to `ip6_route_output_flags'

Needs
	depends on IPV6_MULTIPLE_TABLES || IPV6=n 

Compile testing with IPV6=y and IPV6_MULTIPLE_TABLES=n would have been
great. I'll submit a v3 after some time has passed to review the new
rerouting bits.
