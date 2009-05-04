From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Temporary IPv6 address asignment
Date: Mon, 04 May 2009 19:57:39 +0900 (JST)
Message-ID: <20090504.195739.90161410.yoshfuji@linux-ipv6.org>
References: <49FE18C3.7040702@poczta.fm>
	<20090503.153428.07349534.davem@davemloft.net>
	<49FE1E71.6090500@poczta.fm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: stlman@poczta.fm
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:3355 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZEDLbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 07:31:48 -0400
In-Reply-To: <49FE1E71.6090500@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <49FE1E71.6090500@poczta.fm> (at Mon, 04 May 2009 00:45:05 +0200), Lukasz Stelmach <stlman@poczta.fm> says:

> @@ -188,6 +189,7 @@ enum {
>  	DEVCONF_TEMP_PREFERED_LFT,
>  	DEVCONF_REGEN_MAX_RETRY,
>  	DEVCONF_MAX_DESYNC_FACTOR,
> +	DEVCONF_DESYNC_FACTOR,
>  	DEVCONF_MAX_ADDRESSES,
>  	DEVCONF_FORCE_MLD_VERSION,
>  	DEVCONF_ACCEPT_RA_DEFRTR,

(In addition to the issue regarding sysctl,)
please do not add new DEVCONF_xxx enum in the middle.

--yoshfuji
