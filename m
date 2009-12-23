From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Add Direct Attach to the available connector
 ports
Date: Wed, 23 Dec 2009 17:52:08 -0500
Message-ID: <4B329F18.4070607@garzik.org>
References: <20091125101315.24481.11759.stgit@localhost.localdomain>	 <20091129.003601.253425360.davem@davemloft.net>	 <4B125014.9080507@garzik.org> <1259584513.3709.173.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com,
	=?UTF-8?B?QW7DrWJhbCBNb25zYWx2ZSBTYWxheg==?= =?UTF-8?B?YXI=?=
	<anibal@debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:54242 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbZLWWwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:52:11 -0500
Received: by ywh12 with SMTP id 12so8324304ywh.21
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 14:52:10 -0800 (PST)
In-Reply-To: <1259584513.3709.173.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2009 07:35 AM, Ben Hutchings wrote:
> On Sun, 2009-11-29 at 05:42 -0500, Jeff Garzik wrote:
>> The current scheme just increments a release number: 5->6, 6->7, etc.
>> But with so few kernel releases (and thus ethtool releases), I was
>> leaning towards either yearly release naming ("ethtool-2009"), kernel
>> release naming ("ethtool-2.6.33"), or the release scheme proposed for
>> glibc:  snapshot directly from the git repository.

> I think it should be based on kernel versions, so that it's clear
> whether a given ethtool version supports the features introduced in a
> given kernel version.

Sounds like kernel version it is.  Will debut ethtool-2.6.33 in a week 
or so, then.  I posted ethtool-2.6.33-pre1 just now (intentionally 
different from 2.6.33-rc1, to hint that ethtool release candidates need 
not march in lock step with kernel pre-releases).  Let some bug fixes 
trickle in, and then release ethtool-2.6.33.

	Jeff


