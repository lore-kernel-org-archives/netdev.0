From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: fix neigh tbl index increment race
Date: Mon, 15 Jun 2015 16:04:42 -0700 (PDT)
Message-ID: <20150615.160442.1380881777482747617.davem@davemloft.net>
References: <1434169480-62863-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbFOXEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:04:43 -0400
In-Reply-To: <1434169480-62863-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Fri, 12 Jun 2015 21:24:40 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> rocker->neigh_tbl_next_index is used to generate unique indices for neigh
> entries programmed into the device.  The way new indices were generated was
> racy with the new prepare-commit transaction model.  A simple fix here
> removes the race.  The race was with two processes getting the same index,
> one process using prepare-commit, the other not:
 ...
> Reported-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
