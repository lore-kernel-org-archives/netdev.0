From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] [iproute2] tc/q_htb.c: remove printing of a
 deprecated overhead value previously encoded as a part of mpu field
Date: Wed, 17 Feb 2016 17:51:54 -0800
Message-ID: <20160217175154.4676c8c6@xeon-e3>
References: <3134751450538752@web30j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Phil Sutter <phil@nwl.cc>
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33193 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423483AbcBRBvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 20:51:44 -0500
Received: by mail-pf0-f173.google.com with SMTP id q63so21578998pfb.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 17:51:44 -0800 (PST)
In-Reply-To: <3134751450538752@web30j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Dec 2015 18:25:52 +0300
Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:

> Remove printing according to the previously used encoding of mpu and overhead values within the tc_ratespec's mpu field. This encoding is no longer being used as a separate 'overhead' field in the ratespec structure has been introduced.
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Phil Sutter <phil@nwl.cc>

Both applied.

I had to fix up the commit logs.
Many tools don't like long subject/summary lines, and it is standard practice
to wrap text in commit body at 80 characters.
