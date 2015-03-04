From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Wed, 04 Mar 2015 15:47:06 -0800
Message-ID: <54F7997A.3020604@plumgrid.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41371 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbCDXrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 18:47:06 -0500
Received: by igal13 with SMTP id l13so41572155iga.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 15:47:05 -0800 (PST)
In-Reply-To: <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15 1:14 PM, Guy Harris wrote:
>
> On Mar 4, 2015, at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> the patch is correct and looks clean, but I don't understand
>> the motivation for the patch.
>> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
>> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
>> If there another vlan header inside the packet, it's AD.
>> So you can do the filtering already without adding new bpf extension...
>
> I presume he's referring to
>
> 	https://github.com/the-tcpdump-group/libpcap/issues/397
>
> or
>
> 	https://github.com/the-tcpdump-group/libpcap/issues/390

ok. context is clear.
yet, it still sounds like something to fix inside libpcap.
