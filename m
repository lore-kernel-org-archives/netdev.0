From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] l2tp: Introduce L2TPv3 support
Date: Tue, 23 Mar 2010 11:53:44 -0700 (PDT)
Message-ID: <20100323.115344.134124384.davem@davemloft.net>
References: <2f9409cb1003230319u799ef2e4l583f4f667ffa0169@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: james@jchapman.plus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752844Ab0CWSxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 14:53:22 -0400
In-Reply-To: <2f9409cb1003230319u799ef2e4l583f4f667ffa0169@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <james@jchapman.plus.com>
Date: Tue, 23 Mar 2010 10:19:03 +0000

> scripts/checkpatch.pl didn't pick these up. Is there a recommended way
> to find these in the future? I'm using stg to manage these patches.

GIT warns about them when you try to apply them.

I check patches using a dry run with a script that looks
something like:

#!/bin/sh
set -x
git apply --check --whitespace=error-all $1
