From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH net-next] rndis_host: pass buffer length to
	rndis_command
Date: Thu, 19 Jun 2008 01:04:26 +0300
Message-ID: <20080619010426.ncag3kv5448s4o40@hayate.ip6>
References: <20080618124011.11920.98218.stgit@fate.lan>
	<200806181009.10193.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:49709 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbYFRWE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 18:04:28 -0400
In-Reply-To: <200806181009.10193.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Brownell <david-b@pacbell.net>:

> On Wednesday 18 June 2008, Jussi Kivilinna wrote:
>> Pass buffer length to rndis_command so that rndis_command can read full
>> response buffer from device instead of max CONTROL_BUFFER_SIZE bytes.
>
> That is:  allow rndis_wlan to get responses *bigger* than that size,
> while preserving the requirement that the host must always be ready
> to receive that many bytes.

Exactly.. I should try remember answer to the "why" part in  
description in future.



