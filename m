From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 05 Sep 2013 15:49:23 -0400 (EDT)
Message-ID: <20130905.154923.741417095415435914.davem@davemloft.net>
References: <CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
	<20130905.144044.1053960608071929025.davem@davemloft.net>
	<CAMuHMdVgd499_oAU0oodE8ie+h+Oc6M-dRcyC4tT6QDB=01GSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	azhou@nicira.com, fengguan.wu@intel.com
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab3IETt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:49:26 -0400
In-Reply-To: <CAMuHMdVgd499_oAU0oodE8ie+h+Oc6M-dRcyC4tT6QDB=01GSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 5 Sep 2013 21:20:16 +0200

> Why don't you abort the loop if a difference is found?

We are optimizing for a match.
