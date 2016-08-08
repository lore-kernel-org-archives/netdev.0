From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/2] devlink: write usage help messages to stderr
Date: Mon, 8 Aug 2016 09:19:21 +0200
Message-ID: <20160808071921.GA1944@nanopsycho.orion>
References: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
 <20160723094659.06921b95@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35191 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbcHHHTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 03:19:25 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so13683976wmg.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 00:19:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160723094659.06921b95@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 23, 2016 at 06:46:59PM CEST, stephen@networkplumber.org wrote:
>On Fri, 22 Jul 2016 18:34:29 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> In order to not confuse reader, write help messages into stderr.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>This does make devlink consistent with other parts of iproute2.
>But the most common coding standards, back to Unix, and GNU are
>that help messages should go to stdout so that:
>  $ ip -h | more
>would work as expected.

The thing is I wanted to make stdout only for json. Putting non-json
help out there does not look correct to me. Is it?
