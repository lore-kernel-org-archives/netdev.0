From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 07:50:53 +0100
Message-ID: <20150305065053.GA2062@nanopsycho.orion>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
 <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu>
 <54F7997A.3020604@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guy Harris <guy@alum.mit.edu>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbbCEGvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 01:51:03 -0500
Content-Disposition: inline
In-Reply-To: <54F7997A.3020604@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 05, 2015 at 12:47:06AM CET, ast@plumgrid.com wrote:
>On 3/4/15 1:14 PM, Guy Harris wrote:
>>
>>On Mar 4, 2015, at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>>>the patch is correct and looks clean, but I don't understand
>>>the motivation for the patch.
>>>There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
>>>two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
>>>If there another vlan header inside the packet, it's AD.
>>>So you can do the filtering already without adding new bpf extension...
>>
>>I presume he's referring to
>>
>>	https://github.com/the-tcpdump-group/libpcap/issues/397
>>
>>or
>>
>>	https://github.com/the-tcpdump-group/libpcap/issues/390
>
>ok. context is clear.
>yet, it still sounds like something to fix inside libpcap.

Libpcap need to somehow let kernel now what vlan proto it should filter on.
Also, it is not true that another vlan header inside packet is AD. You
can have packet with just AD header (or 2 AD or 2 Q, etc).
