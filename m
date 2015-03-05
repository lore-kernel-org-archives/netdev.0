From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 05 Mar 2015 12:40:42 -0800
Message-ID: <54F8BF4A.3090702@plumgrid.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <20150305103715.GA3432@morgoth.brq.redhat.com> <54F889EB.7000203@plumgrid.com> <54F8B680.4050307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	guy@alum.mit.edu, atzm@stratosphere.co.jp
To: Daniel Borkmann <daniel@iogearbox.net>,
	Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36231 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758656AbbCEUki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:40:38 -0500
Received: by igkb16 with SMTP id b16so49224315igk.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:40:37 -0800 (PST)
In-Reply-To: <54F8B680.4050307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15 12:03 PM, Daniel Borkmann wrote:
> On 03/05/2015 05:52 PM, Alexei Starovoitov wrote:
>> imo there is a benefit of giving programs more visibility into
>> skb metadata.
>
> I'm not really a big fan of it, but given we added commit a0cdfcf39362
> ("packet: deliver VLAN TPID to userspace") to packet sockets ...

good point, since skb->vlan_proto is already exposed to user space
via that commit, it makes sense to let bpf see it as well.
For consistency with tpacket, I'd call it SKF_AD_VLAN_TPID
