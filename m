From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Sat, 07 Sep 2013 21:48:24 -0400 (EDT)
Message-ID: <20130907.214824.1685385647443815510.davem@davemloft.net>
References: <504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
	<20130907.002952.1951928882694928547.davem@davemloft.net>
	<CAM8tLiPCUS3_jo4KU1zY9+8wRg08fA0ohH9d+0a4jyC69D9JZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, mschmidt@redhat.com, netdev@vger.kernel.org,
	ariele@broadcom.com, eilong@broadcom.com
To: dkravkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab3IHBs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 21:48:28 -0400
In-Reply-To: <CAM8tLiPCUS3_jo4KU1zY9+8wRg08fA0ohH9d+0a4jyC69D9JZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dkravkov@gmail.com>
Date: Sat, 7 Sep 2013 12:07:50 +0300

> On Sat, Sep 7, 2013 at 7:29 AM, David Miller <davem@davemloft.net> wrote:
>> Probe should never fail because of an atomic memory allocation if at
>> all possible.
> We here are in open() flow, not probe()

It's the same from my perspective.

Better to drop some packets than have _COMPLETELY INOPERATIVE INTERFACE_.
