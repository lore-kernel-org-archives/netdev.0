From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2 1/2] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Sat, 14 Apr 2012 14:32:01 +0200
Message-ID: <CA+1xoqdOqy8-Nkk00ZoCcUNLLvz0n6ZFyefsP8GoJhpepfVNtg@mail.gmail.com>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com>
 <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg> <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
 <alpine.LFD.2.00.1204141518270.9966@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net,
	davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64673 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455Ab2DNMcW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 08:32:22 -0400
In-Reply-To: <alpine.LFD.2.00.1204141518270.9966@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 14, 2012 at 2:23 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Sat, 14 Apr 2012, Sasha Levin wrote:
>
>> On Sat, Apr 14, 2012 at 1:53 PM, Julian Anastasov <ja@ssi.bg> wrote:
>> > =A0 =A0 =A0 =A0Ops. It seems now we expose old problem when
>> > no protocol is configured. As this change probably will
>> > go to stable kernels, lets make it correct. Can you
>> > remove the defines around register_ip_vs_proto_netns, so
>> > that it is always compiled. One that wants to save
>> > memory will not disable all protocols. See commit
>> > 091bb34c143674d37a59b2d4857534f7106c5d7d for reference.
>>
>> Oh, so it wasn't getting built right now at all if we didn't select
>> any protocols.
>>
>> How about moving those defines down to our loop as well? this way
>> everything will behave exactly like it did before.
>
> =A0 =A0 =A0 =A0Better to remove the defines. It is a misconfiguration
> to enable IPVS without protocols. The referenced commit
> just tried to remove warnings, not save memory by commenting
> unused function. Adding more define makes the things more ugly.

Understood. I'll resend.
