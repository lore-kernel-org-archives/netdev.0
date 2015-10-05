From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: IPv6 support for ovs_tunnel_get_egress_info
Date: Mon, 5 Oct 2015 11:05:00 -0700
Message-ID: <CALnjE+q_nPothrfHdwLZXTVu2MwJipFsUy-jQhpPPEbOKT3DeQ@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
	<8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
	<CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
	<20151002080041.52017d26@griffin>
	<CALnjE+qn7PrEYxKZ6c03-Bz63BcROVuqmwdp8sqi2eXvxY-yeg@mail.gmail.com>
	<CAEP_g=9WbT15vWUpUemq5c_b90U7LfbVRWDt0DSHGoqnqyZL+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33268 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbJESFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 14:05:01 -0400
Received: by iofh134 with SMTP id h134so195139038iof.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 11:05:01 -0700 (PDT)
In-Reply-To: <CAEP_g=9WbT15vWUpUemq5c_b90U7LfbVRWDt0DSHGoqnqyZL+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 2, 2015 at 5:57 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Oct 2, 2015 at 12:32 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Thu, Oct 1, 2015 at 11:00 PM, Jiri Benc <jbenc@redhat.com> wrote:
>>> On Thu, 1 Oct 2015 17:11:56 -0700, Pravin Shelar wrote:
>>>> I dont see point of adding this code when IPv6 sampling not support by
>>>> the patch series.
>>>
>>> It was requested by Jesse:
>>> http://article.gmane.org/gmane.linux.network/380348
>>>
>>
>> I don't think we can use this function, lwtunnel device need new ndo_
>> operation to export this information. So lets defer this patch till we
>> have solution for retrieving egress info from lwtunnel devices.
>
> I don't entirely disagree with this but I'm also nervous about
> completely leaving it out. It seems like when this issue does get
> fixed, it is likely that the person who does it will just convert
> whatever code is there and not necessarily think about IPv6 since it's
> not an IPv6 feature. If that happens, we'll have a hidden problem in
> IPv6, which is somewhat unfortunately as try to advance IPv6 forward.

The code is pretty different for different tunnel. It is possible to
take the code and reuse it. But that would involve lot of refactoring
into existing code for every flow tunnel based tunnel implementation.
I do not want to do it as part of fix to net branch.
I have sent out patch to fix the egress tunnel info issue with
lwtunnel. Once that is merged we can have complete IPv6 tunnel support
on net-next.
