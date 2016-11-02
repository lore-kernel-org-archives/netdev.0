From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 3/5] bpf: BPF for lightweight tunnel encapsulation
Date: Wed, 2 Nov 2016 16:58:42 -0600
Message-ID: <CACby=pn5=uhR12fv9ebat2Pkk3kzOUhxGVOWp+gn+jxf7ud2rA@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <d8c7e07ac7d289a2846af8d659287f3512a4edec.1477959702.git.tgraf@suug.ch>
 <5819EC81.90405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:33223 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754442AbcKBW6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 18:58:44 -0400
Received: by mail-vk0-f44.google.com with SMTP id d65so25963649vkg.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 15:58:43 -0700 (PDT)
In-Reply-To: <5819EC81.90405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 November 2016 at 07:39, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> diff --git a/net/core/Makefile b/net/core/Makefile
>> index d6508c2..a675fd3 100644
>> --- a/net/core/Makefile
>> +++ b/net/core/Makefile
>> @@ -23,7 +23,7 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
>>  obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
>>  obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
>>  obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
>> -obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
>> +obj-$(CONFIG_LWTUNNEL) += lwtunnel.o lwt_bpf.o
>
> Any reason you want to keep lwt bpf under the main CONFIG_LWTUNNEL infra config ?.
> since it is defined as yet another plug-gable encap function, seems like it will be better under a separate
> CONFIG_LWTUNNEL_BPF or CONFIG_LWT_BPF that depends on CONFIG_LWTUNNEL

The code was so minimal with no additional dependencies that I didn't
see a need for a separate Kconfig. I'm fine adding that in the next
iteration though. No objections.
