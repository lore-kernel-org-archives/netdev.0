From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 08:22:21 +0100
Message-ID: <20130125072221.GB1659@minipsycho.orion>
References: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
 <13906.1359077701@death.nxdomain>
 <20130125063713.GA1659@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:52483 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3AYHW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 02:22:26 -0500
Received: by mail-we0-f179.google.com with SMTP id x43so29967wey.24
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 23:22:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130125063713.GA1659@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 25, 2013 at 07:37:13AM CET, jiri@resnulli.us wrote:
>Fri, Jan 25, 2013 at 02:35:01AM CET, fubar@us.ibm.com wrote:
>>Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>>Makes more sense to have randomly generated address by default than to
>>>have all zeroes. It also allows user to for example put the bond into
>>>bridge without need to have any slaves in it.
>>>
>>>Also note that this changes only behaviour of bonds with no slaves. Once
>>>the first slave device is enslaved, its address will be used (no change
>>>here).


Also, this is not entirely true now. Example:

eth1 has 52:54:00:b8:30:0b

# ip link add bondx address 22:33:44:55:66:77 type bond
# ip link set eth1 master bondx

Now both bondx and eth1 has 22:33:44:55:66:77

Shouldn't both have 52:54:00:b8:30:0b ?
