From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Thu, 16 Feb 2017 16:08:52 +1300
Message-ID: <878tp6al2z.fsf@xmission.com>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
        <87h93xqlui.fsf@xmission.com>
        <cc15d1fa-dd38-c01b-7a42-9eaf206d98a2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42444 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdBPDNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 22:13:32 -0500
In-Reply-To: <cc15d1fa-dd38-c01b-7a42-9eaf206d98a2@cumulusnetworks.com> (David
        Ahern's message of "Wed, 15 Feb 2017 19:16:03 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 2/14/17 12:21 AM, Eric W. Biederman wrote:
>>> in cases where bpf programs are looking at sockets and packets
>>> that belong to different netns, it could be useful to get an id
>>> that uniquely identify a netns within the whole system.
>> It could be useful but there is no unique namespace id.
>> 
>
> Have you given thought to a unique namespace id? Networking tracepoints
> for example could really benefit from a unique id.

An id from the perspective of a process in the initial instance of every
namespace is certainly possible.

A truly unique id is just not maintainable.  Think of the question how
do you assign every device in the world a rguaranteed unique ip address
without coordination, that is routable.  It is essentially the same
problem.

AKA it is theoretically possible and very expensive.  It is much easier
and much more maintainable for identifiers to have scope and only be
unique within that scope.

Eric
