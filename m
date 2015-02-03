From: Moni Shoua <monis@mellanox.com>
Subject: Re: [PATCH net-next 03/10] net/bonding: Notify state change on slaves
Date: Tue, 3 Feb 2015 19:17:38 +0200
Message-ID: <CAG9sBKPPGFVRTeKFhG_86coxgHp_bBYaQ4M50T8hDjZMew8gig@mail.gmail.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
	<1422974919-28084-4-git-send-email-ogerlitz@mellanox.com>
	<54D0F2B7.4000005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:33100 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965829AbbBCRRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:17:39 -0500
Received: by mail-qa0-f47.google.com with SMTP id n8so34845136qaq.6
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 09:17:39 -0800 (PST)
In-Reply-To: <54D0F2B7.4000005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Or,
> A few questions below,
>
Hi Nik
You are probably right about the problem of de-referencing slave
inside a work. I didn't think of the scenario of release the dev and
re-enslaving it to another bond while the work is still pending in the
queue.
I'll fix this and the memory leak you noticed in the next set
thanks
Moni
