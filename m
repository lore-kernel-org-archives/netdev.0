From: David Wragg <david@weave.works>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Wed, 10 Feb 2016 11:41:55 +0000
Message-ID: <86a8n86bcs.fsf@weave.works>
References: <1455036424-6403-1-git-send-email-david@weave.works>
	<1455036424-6403-3-git-send-email-david@weave.works>
	<CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	dev@openvswitch.org, Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35552 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbcBJLl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 06:41:58 -0500
Received: by mail-wm0-f54.google.com with SMTP id c200so24352006wme.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 03:41:57 -0800 (PST)
In-Reply-To: <CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
	(Tom Herbert's message of "Wed, 10 Feb 2016 08:40:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:
> The correct thing to do is determine the maximum amount of
> encapsulation overhead that can ever be set in a packet and use for
> setting the MTU. For instance, when RCO is enable in GUE, the size of
> the option is included in tunnel->encap_hlen even though it will not
> be used in all packets (via ip_tunnel_change_mtu). If there is no way
> to determine a maximum overhead a priori from configuration, then
> maximum overhead could be assumed to be maximum possible encapsulation
> header size which for Geneve is 132 bytes IIRC.

Ok, I'll come up with a patch to address this.

David
