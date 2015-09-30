From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6 tunneling
Date: Wed, 30 Sep 2015 14:29:09 -0700
Message-ID: <CAEP_g=_rHyaW87Tit52Y4dF_p1xicQ6i049deJHhCnNK8pYb6g@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com> <ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
 <CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com>
 <20150930092850.09b71dff@griffin> <CAEP_g=_OWHD8AuO5t3aTEJVNDHihpjzfz29ppoE1Ownm8PgRJw@mail.gmail.com>
 <20150930230554.4c6889d0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:35306 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbbI3V3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:29:30 -0400
Received: by laer8 with SMTP id r8so61902893lae.2
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 14:29:29 -0700 (PDT)
In-Reply-To: <20150930230554.4c6889d0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 2:05 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 30 Sep 2015 13:18:40 -0700, Jesse Gross wrote:
>> This function is used to report back information that is the result of
>> the encapsulation process, such as the UDP source port chosen. Take a
>> look at net/openvswitch/actions.c:output_userspace(), particularly the
>> OVS_USERSPACE_ATTR_EGRESS_TUN_PORT case.
>
> I see. I think it should be addressed separately from this patchset,
> though, as the function needs to be completely rewritten even for IPv4
> and IPv6 can be handled alongside it.
>
> I'll change the patch description in v2, the current wording is not
> correct. I don't think that fixing the bug should be a prerequisite for
> this patchset, the problem is already there and this patchset doesn't
> change that.

Can you at least update the existing code for IPv6 so that this
doesn't introduce another lurking issue when the bug is fixed?
