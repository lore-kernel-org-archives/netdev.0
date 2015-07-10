From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 0/2] net: enable inband link state negotiation only
 when explicitly requested
Date: Fri, 10 Jul 2015 13:31:51 -0700
Message-ID: <55A02BB7.8080902@gmail.com>
References: <559FF511.5080102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34205 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbbGJUdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 16:33:36 -0400
In-Reply-To: <559FF511.5080102@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/15 09:38, Stas Sergeev wrote:
> Hello.
> 
> Currently the link status auto-negotiation is enabled
> for any SGMII link with fixed-link DT binding.
> The regression was reported:
> https://lkml.org/lkml/2015/7/8/865
> Apparently not all HW that implements SGMII protocol, generates the
> inband status for the auto-negotiation to work.
> More details here:
> https://lkml.org/lkml/2015/7/10/206
> 
> The following patches reverts to the old behavior by default,
> which is to not enable the auto-negotiation for fixed-link.
> The new DT property is added that allows to explicitly request
> the auto-negotiation.
> 
> Those who were affected by the change, please send your Tested-by,
> Thanks!

For future submissions, would you mind CC'ing everybody for the entire
patch series and not just on a per-patch basis?
-- 
Florian
