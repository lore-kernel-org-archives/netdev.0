From: David Wragg <david@weave.works>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Thu, 18 Feb 2016 16:54:14 +0000
Message-ID: <86bn7e2c3t.fsf@weave.works>
References: <1455036424-6403-1-git-send-email-david@weave.works>
	<1455036424-6403-3-git-send-email-david@weave.works>
	<CALx6S37sD+MNK+kp9oLnEYHEUkOy_NdQK6bq-aMQP2Mvw9M4Qg@mail.gmail.com>
	<86a8n86bcs.fsf@weave.works>
	<CAEh+42iGHk9zVYPcpSz5w5XPg450p8avuQLbMZZH+B5fZvF9WQ@mail.gmail.com>
	<CALx6S36kvXJUZM8_vEmF8L3bxnRiBh98Rs0wAd-HGBJ9Yyde_Q@mail.gmail.com>
	<CAEh+42gyHEALCjZZGjMWTLQsPgp191c4dfZYFffOL6iV7pwYHw@mail.gmail.com>
	<86vb5o3kd5.fsf@weave.works>
	<CALx6S37OgkxTLv6XEjFN4T=W8ZdZV_kx4wtPqtVwMizoUXbpVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35244 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbcBRQyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:54:16 -0500
Received: by mail-wm0-f54.google.com with SMTP id c200so37522712wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 08:54:16 -0800 (PST)
In-Reply-To: <CALx6S37OgkxTLv6XEjFN4T=W8ZdZV_kx4wtPqtVwMizoUXbpVw@mail.gmail.com>
	(Tom Herbert's message of "Tue, 16 Feb 2016 08:44:02 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:
> Please implement like in ip_tunnel_change_mtu (or better yet call it),
> that is the precedent for tunnels.

I've made geneve_change_mtu follow ip_tunnel_change_mtu in v2.

If it were to call it instead, are you suggesting just passing in
t_hlen?  Or restructuring geneve.c to re-use the whole ip_tunnel
infrastructure?

Also, I'm not sure where the 0xFFF8 comes from in
__ip_tunnel_change_mtu.  Any ideas why 0xFFF8 rather than 0xffff?  It
goes all the way back to the inital import of the kernel into git.

David
