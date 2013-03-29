From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 17:13:36 -0700
Message-ID: <1364516016.15753.59.camel@edumazet-glaptop>
References: <20130328150410.GA22789@sergelap>
	 <CD7A1D9A.78BA%blourdel@juniper.net>
	 <20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	 <87zjxn84ks.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:57307 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab3C2ANj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 20:13:39 -0400
Received: by mail-pb0-f50.google.com with SMTP id jt11so35039pbb.23
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 17:13:38 -0700 (PDT)
In-Reply-To: <87zjxn84ks.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 16:52 -0700, Eric W. Biederman wrote:

> On my microbenchmark of just creating 5000 veth pairs this takes pairs
> 16s instead of 13s of my earlier hacks but that is well down in the
> usable range.

I guess most of the time is taken by sysctl_check_table()
