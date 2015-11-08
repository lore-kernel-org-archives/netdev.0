From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: AF_PACKET mmap() v4...
Date: Sat, 7 Nov 2015 18:19:59 -0800
Message-ID: <20151108021958.GA39441@ast-mbp.thefacebook.com>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
 <4931220.z2MFa8LzkQ@wuerfel>
 <563B23C3.5070406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34260 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbbKHCUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 21:20:06 -0500
Received: by padhx2 with SMTP id hx2so153318873pad.1
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 18:20:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <563B23C3.5070406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2015 at 10:39:15AM +0100, Daniel Borkmann wrote:
> On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
> >On Thursday 05 November 2015 00:04:14 David Miller wrote:
> >>As part of fixing y2038 problems, Arnd is going to have to make a new
> >>version fo the AF_PACKET mmap() tpacker descriptors in order to extend
> >>the time values to 64-bit.

would also be quite useful to add ability to attach metadata to packet
from bpf program.
Right now we can only trim the length. Would be great if program could
compute something and pass it along with packet as metadata.
