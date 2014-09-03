From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next iproute2 v2] iproute2: allow to change slave
 options via type_slave
Date: Wed, 3 Sep 2014 18:04:51 +0200
Message-ID: <20140903160451.GB1843@nanopsycho.lan>
References: <20140903150215.GA1843@nanopsycho.lan>
 <1409759850-15812-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:37267 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbaICQEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 12:04:55 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so8755820wgh.7
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 09:04:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1409759850-15812-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 03, 2014 at 05:57:30PM CEST, nikolay@redhat.com wrote:
>This patch adds the necessary changes to allow altering a slave device's
>options via ip link set <device> type <master type>_slave specific-option.
>It also adds support to set the bonding slaves' queue_id.
>
>Example:
> ip link set eth0 type bond_slave queue_id 10
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
