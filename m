From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1
 and xdp_tx_iptunnel
Date: Sun, 30 Apr 2017 17:46:13 -0600
Message-ID: <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
References: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
 <20170428234035.5f0beec6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36804 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034683AbdD3XqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 19:46:14 -0400
Received: by mail-io0-f177.google.com with SMTP id p80so101462225iop.3
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 16:46:13 -0700 (PDT)
In-Reply-To: <20170428234035.5f0beec6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 3:40 PM, Jesper Dangaard Brouer wrote:
> [...]
>> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
>> index 0d449d8032d1..d4433a47e6c3 100644
>> --- a/samples/bpf/bpf_load.c
>> +++ b/samples/bpf/bpf_load.c
>> @@ -563,7 +563,7 @@ struct ksym *ksym_search(long key)
>>  	return &syms[0];
>>  }
>>  
>> -int set_link_xdp_fd(int ifindex, int fd)
>> +int set_link_xdp_fd(int ifindex, int fd, int flags)
> Shouldn't the flags be a unsigned int, actually a __u32 ?
> 

sure. I'll send a patch
