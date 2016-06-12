From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [RFC PATCH iproute2] tc: let m_ipt work with new iptables API
 headers
Date: Sun, 12 Jun 2016 23:30:40 +0200
Message-ID: <3e654b82-2e16-7a5e-62cc-c137b7b75a5c@pengutronix.de>
References: <20160529182713.2131-1-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, clemens.gruber@pqgruber.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53044 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932156AbcFLVam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 17:30:42 -0400
In-Reply-To: <20160529182713.2131-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On 05/29/2016 08:27 PM, Alexander Aring wrote:
> Since commit 5cd1adb ("Update to current iptables headers") the build
> with m_ipt.o and the following config will fail:
> 
> TC_CONFIG_XT:=n
> TC_CONFIG_XT_OLD:=n
> TC_CONFIG_XT_OLD_H:=n
> 
> This patch renames "iptables_target" to "xtables_target" and some other
> things which gets renamed and I noticed while reading iptables git log.
> Functions which are not used in m_ipt.c and not exported by the header
> are removed, if they still used in m_ipt.c I added a static to the function.
> 
> Reported-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
> I removed also "linux/if.h" because some redifinition errors and seems
> not be necessary anymore.
> 
> I didn't test this implementation, I just fix the compile issues at m_ipt
> implementation according to the algoritmn described above.
> 
> Maybe there are more TC_CONFIG_XT* config variants broken than just m_ipt?
> 

ping, any comments to this patch?
I can rebase and resend this patch if necessary.

- Alex
