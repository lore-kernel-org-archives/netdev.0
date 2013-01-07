From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH repost] net,wireless: check against default_ethtool_ops
Date: Mon, 7 Jan 2013 12:11:08 +0100
Message-ID: <20130107111108.GB1587@minipsycho.orion>
References: <20130107095548.GA6931@redhat.com>
 <20130107102307.GA1587@minipsycho.orion>
 <20130107104413.GB6931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-wireless@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:59129 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681Ab3AGLLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 06:11:13 -0500
Received: by mail-wg0-f50.google.com with SMTP id es5so9704020wgb.5
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 03:11:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130107104413.GB6931@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 07, 2013 at 11:44:14AM CET, sgruszka@redhat.com wrote:
>On Mon, Jan 07, 2013 at 11:23:07AM +0100, Jiri Pirko wrote:
>> >-static const struct ethtool_ops default_ethtool_ops;
>> >+const struct ethtool_ops default_ethtool_ops;
>> >+EXPORT_SYMBOL_GPL(default_ethtool_ops);
>> 
>> I think that default_ethtool_ops should stay static. Wouldn't it be
>> nicer to introduce a helper like:
>> 
>> bool dev_has_default_ethtool_ops(struct net_device *dev)
>> {
>> 	return dev->ethtool_ops == &default_ethtool_ops;
>> }
>
>Then I still have to export this function. So with your approch, number
>of exported symbols will be the same, but there will be few more lines
>of code.

I think it's always better to add few more lines in order to prevent possible
confusion which exporting default_ethtool_ops might introduce...

>
>Stanislaw
