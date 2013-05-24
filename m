From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Fri, 24 May 2013 11:58:20 -0700
Message-ID: <1369421900.3301.431.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:38219 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab3EXS6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 14:58:21 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so4553391pbc.35
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 11:58:21 -0700 (PDT)
In-Reply-To: <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 10:24 -0700, Jesse Gross wrote:

> Does this have any impact on small packets? Those are usually the
> common case (i.e. TCP SYN) and I think this is slightly less optimal
> for those.

No difference at all, small packets are copied anyway in skb->head
