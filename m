From: David Wragg <david@weave.works>
Subject: Re: [PATCH net] geneve: Refine MTU limit
Date: Thu, 18 Feb 2016 16:41:17 +0000
Message-ID: <86fuwq2cpe.fsf@weave.works>
References: <1455625999-9781-1-git-send-email-david@weave.works>
	<CAEh+42i628VNoXh5=vtFKzqVGeF4NqY3=GKbdNVeqmYnWK_oBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Wragg <david@weave.works>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33840 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946232AbcBRQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:41:19 -0500
Received: by mail-wm0-f47.google.com with SMTP id b205so33320967wmb.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 08:41:19 -0800 (PST)
In-Reply-To: <CAEh+42i628VNoXh5=vtFKzqVGeF4NqY3=GKbdNVeqmYnWK_oBg@mail.gmail.com>
	(Jesse Gross's message of "Tue, 16 Feb 2016 10:32:15 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@kernel.org> writes:
> In addition to Tom's comment about taking into account
> dev->hard_header_len, can you please not include
> GENEVE_MAX_OPTIONS_LEN in the MTU calculation based on the discussion
> on the other thread? Otherwise, you are excluding some potentially
> valid configurations.

Addressed in v2.

David
