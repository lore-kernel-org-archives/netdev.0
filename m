From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] iproute2: ip link: add support for network device
 groups
Date: Tue, 11 Jan 2011 07:38:30 -0500
Message-ID: <1294749510.3157.2.camel@mojatatu>
References: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
	 <20110110084700.17798894@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33326 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab1AKMif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 07:38:35 -0500
Received: by gwj20 with SMTP id 20so8905812gwj.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 04:38:34 -0800 (PST)
In-Reply-To: <20110110084700.17798894@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 08:47 -0800, Stephen Hemminger wrote:

> I like the idea, but I wonder if we should take it farther?
> Should it be hierarchal tree of groups?
> Should slave devices (ppp, vlan, etc) be automatically assigned
> to group of parent?

I think that would be treading into policy land.
The whole point is that the admin sets this value (just like the
skb->mark) and specifies how it is to be used.

cheers,
jamal

