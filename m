From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6
 tunneling
Date: Wed, 30 Sep 2015 23:05:54 +0200
Message-ID: <20150930230554.4c6889d0@griffin>
References: <cover.1443548447.git.jbenc@redhat.com>
	<ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
	<CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com>
	<20150930092850.09b71dff@griffin>
	<CAEP_g=_OWHD8AuO5t3aTEJVNDHihpjzfz29ppoE1Ownm8PgRJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753675AbbI3VF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 17:05:58 -0400
In-Reply-To: <CAEP_g=_OWHD8AuO5t3aTEJVNDHihpjzfz29ppoE1Ownm8PgRJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Sep 2015 13:18:40 -0700, Jesse Gross wrote:
> This function is used to report back information that is the result of
> the encapsulation process, such as the UDP source port chosen. Take a
> look at net/openvswitch/actions.c:output_userspace(), particularly the
> OVS_USERSPACE_ATTR_EGRESS_TUN_PORT case.

I see. I think it should be addressed separately from this patchset,
though, as the function needs to be completely rewritten even for IPv4
and IPv6 can be handled alongside it.

I'll change the patch description in v2, the current wording is not
correct. I don't think that fixing the bug should be a prerequisite for
this patchset, the problem is already there and this patchset doesn't
change that.

 Jiri

-- 
Jiri Benc
