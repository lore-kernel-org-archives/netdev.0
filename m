From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to enable
 sock modifications
Date: Tue, 29 Nov 2016 18:07:18 -0700
Message-ID: <d3359d0c-8995-d605-cd2d-f0558fdd0408@cumulusnetworks.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
 <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
 <20161130005906.GB29591@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34290 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcK3BHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:07:21 -0500
Received: by mail-pg0-f41.google.com with SMTP id x23so75426854pgx.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 17:07:21 -0800 (PST)
In-Reply-To: <20161130005906.GB29591@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 5:59 PM, Alexei Starovoitov wrote:
> On Tue, Nov 29, 2016 at 05:43:08PM -0700, David Ahern wrote:
>> On 11/29/16 1:01 PM, Alexei Starovoitov wrote:
>>> Could you also expose sk_protcol and sk_type as read only fields?
>>
>> Those are bitfields in struct sock, so can't use offsetof or sizeof. Any existing use cases that try to load a bitfield in a bpf that I can look at?
> 
> pkt_type, vlan are also bitfileds in skb. Please see convert_skb_access()
> There is a bit of ugliness due to __BIG_ENDIAN_BITFIELD though..
> 

Given the added complexity I'd prefer to defer this second use case to a follow on patch set. This one introduces the infra for sockets and I don't see anything needing to change with it to add the read of 3 more sock elements. Agree?
