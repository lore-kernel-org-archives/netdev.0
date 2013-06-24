From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Mon, 24 Jun 2013 08:42:59 -0700
Message-ID: <20130624084259.4c2211a4@nehalam.linuxnetplumber.net>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ryousei Takano <takano-ryousei@aist.go.jp>,
	Amir Vadai <amirv@mellanox.com>
To: Pawit Pornkitprasan <p.pawit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:40694 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab3FXPnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 11:43:04 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so11167224pbc.32
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:43:02 -0700 (PDT)
In-Reply-To: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jun 2013 16:55:00 +0900
Pawit Pornkitprasan <p.pawit@gmail.com> wrote:

> [1.] One line summary of the problem:
> Bridging does not work with Mellanox ConnectX-2 (mlx4_en) card in SR-IOV mode

For security reasons, SR-IOV cards to not support promiscuous mode required for bridging.
Also the hardware usually can't do fanout to multiple VF's for same unicast packet.
