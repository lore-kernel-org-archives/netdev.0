From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d
 class show dev <device_name> ' command
Date: Thu, 17 Dec 2015 14:11:30 +0100
Message-ID: <20151217131130.GC1980@orbyte.ovh.net>
References: <5917221449918579@web5j.yandex.ru>
 <20151216161558.265296c7@redhat.com>
 <740111450344461@web24h.yandex.ru>
 <907481450345533@web24h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39099 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215AbbLQNRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 08:17:36 -0500
Content-Disposition: inline
In-Reply-To: <907481450345533@web24h.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 12:45:33PM +0300, Dmitrii Shcherbakov wrote:
> >I don't think your patch should contain this cleanup of "b4".
> 
> It seems that b3 is only used for the legacy overhead part and if I remove it, b3 is not going to be used. So I figured I remove b4 put b3 instead.

No worries, your intentions are good per se. All he wants from you is to
split changes up: a dedicated patch for mpu->overhead conversion and a
second one dedicated for SPRINT_BUF variable cleanup.

HTH, Phil
