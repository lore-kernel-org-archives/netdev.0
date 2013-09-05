From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from analyzers
Date: Thu, 05 Sep 2013 21:59:28 +0200
Message-ID: <5228E2A0.4010607@redhat.com>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com> <20130905.144442.2085221662776542385.davem@davemloft.net> <5228DFF0.7070106@redhat.com> <20130905.155417.2121308426258876038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412Ab3IET7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 15:59:34 -0400
In-Reply-To: <20130905.155417.2121308426258876038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2013 09:54 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 05 Sep 2013 21:48:00 +0200
>
>> With socket(PF_PACKET, ..., htons(ETH_P_ALL)) you will already get
>> all users from the suggested white-list of the patch, which is the
>> majority of netlink users I believe. Hence, you do not need to have
>> one socket per protocol. skbs from there should get dragged into
>> pf_packet via dev_queue_xmit_nit() which works on ptype_all list.
>
> What about user level netlink protocols?

If you are referring to NETLINK_USERSOCK, then we let this pass here,
so nothing changes.
