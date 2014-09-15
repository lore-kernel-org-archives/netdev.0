From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute: update dsfield file values
Date: Mon, 15 Sep 2014 04:48:19 -0700
Message-ID: <1410781699.7106.153.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140914204353.5a0579be@urahara>
	 <20140915130608.5d238cb1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:57678 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbaIOLsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 07:48:21 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so6041210pdj.20
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 04:48:20 -0700 (PDT)
In-Reply-To: <20140915130608.5d238cb1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-15 at 13:06 +0200, Jesper Dangaard Brouer wrote:

> Is it a bug, that we put DSCP's Expedited Forwarding (EF) into the
> best-effort priority band(1) in pfifo_fast???
> 

With 3 bands pfifo_fast, its hard to please everyone.

Using 5 or 6 bands would be more generic ;)
