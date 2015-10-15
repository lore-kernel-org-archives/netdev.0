From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking option
Date: Fri, 16 Oct 2015 00:07:12 +0200
Message-ID: <87r3kv3hwv.fsf@stressinduktion.org>
References: <cover.1444926905.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:47144 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753306AbbJOWHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 18:07:25 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 9A8B721923
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 18:07:14 -0400 (EDT)
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc <jbenc@redhat.com> writes:

> Before using this new facility, the application should check whether it is
> supported by the kernel. This is done by sending a NLMSG_NOOP message with
> NLM_F_REQUEST | NLM_F_STRICT | NLM_F_ACK flags set. If the returned message
> has NLM_F_STRICT set, the kernel does support NLM_F_STRICT flag; otherwise,
> the flag should not be used.

Do you plan to update rfc3549, too? :}

Bye,
Hannes
