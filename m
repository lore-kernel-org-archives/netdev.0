From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 04 Jan 2017 23:26:26 +0100
Message-ID: <586D7692.4000604@iogearbox.net>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com> <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com> <586D7437.1050708@iogearbox.net> <20170104222224.GA31756@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        willemb@google.com, davem@davemloft.net, shuah@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44575 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754021AbdADW0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 17:26:31 -0500
In-Reply-To: <20170104222224.GA31756@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 11:22 PM, Sowmini Varadhan wrote:
> On (01/04/17 23:16), Daniel Borkmann wrote:
>>
>> Just reading up on the thread, sorry to jump in late. Can't you just
>> use the generated code from bpf_asm (tools/net/) and add the asm program
>> as a comment above? Something like we do in net/core/ptp_classifier.c +13.
>
> I was actually using the example from the BSD bpf(4) man page,
> and expanding on that one..
>    https://www.freebsd.org/cgi/man.cgi?query=bpf&sektion=4&manpath=FreeBSD+4.7-RELEASE
> (I could not find the equivalent linux man page).
>
> It was a lot easier to parse than the existing code .

cBPF with its tooling is all documented here:

   Documentation/networking/filter.txt

>> As it stands it makes it a bit harder to parse / less readable with macros
>> actually. Rest seems fine, thanks.
>
> You think the earlier code was readable? I had to use
> gcc -E, with help from the bpf(4) page, to make sense of it.
>
> --Sowmini
>
>
