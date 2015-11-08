From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: AF_PACKET mmap() v4...
Date: Sat, 07 Nov 2015 20:27:07 -0800
Message-ID: <563ECF1B.1000306@gmail.com>
References: <20151105.000414.1682124328670738318.davem@davemloft.net> <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net> <20151108021958.GA39441@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33136 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbbKHE12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 23:27:28 -0500
Received: by pabfh17 with SMTP id fh17so163409616pab.0
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 20:27:27 -0800 (PST)
In-Reply-To: <20151108021958.GA39441@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-11-07 06:19 PM, Alexei Starovoitov wrote:
> On Thu, Nov 05, 2015 at 10:39:15AM +0100, Daniel Borkmann wrote:
>> On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
>>> On Thursday 05 November 2015 00:04:14 David Miller wrote:
>>>> As part of fixing y2038 problems, Arnd is going to have to make a new
>>>> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
>>>> the time values to 64-bit.
> 
> would also be quite useful to add ability to attach metadata to packet
> from bpf program.
> Right now we can only trim the length. Would be great if program could
> compute something and pass it along with packet as metadata.

Also most modern NICs can generate metadata using packet filters
it would be nice to allow these to populate any metadata fields as well.
Ethtool already has a flow classifier feature that could be easily
extended once the stack has support.

.John


> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
