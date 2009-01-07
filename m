From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Wed, 07 Jan 2009 09:24:43 +0100
Message-ID: <874p0bmsl0.fsf@macbook.be.48ers.dk>
References: <20090106091050.GA19316@localhost>
	<87zli4u71i.fsf@macbook.be.48ers.dk>
	<20090106094757.GA19587@localhost>
	<87r63gu1i3.fsf@macbook.be.48ers.dk> <20090107045258.GA8071@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:50152 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbZAGIYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 03:24:53 -0500
Received: by ewy10 with SMTP id 10so8879316ewy.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 00:24:51 -0800 (PST)
In-Reply-To: <20090107045258.GA8071@localhost> (Wu Fengguang's message of "Wed\, 7 Jan 2009 12\:52\:58 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

Hi,

 >> Also, it seems like you're not writing the random address to the
 >> hardware registers, so you won't be able to receive any unicast -
 >> You'll need to add a call to dm9601_set_mac_address() or similar.

 Wu> Good catch. I had wanted to ask why it only works with promisc
 Wu> mode ;-)

;)

 Wu> Here is the tested patch.

 Wu> Thanks,
 Wu> Fengguang
 Wu> ---
 Wu> dm9601: tell HW about random generated mac address

 Wu> Otherwise unicast RX will only work in promisc mode.

 Wu> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
 Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
