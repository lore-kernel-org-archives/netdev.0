From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Fri, 16 Nov 2012 08:29:26 -0800
Message-ID: <20121116082926.1c6cccd2@nehalam.linuxnetplumber.net>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
	<1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40295 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab2KPQac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 11:30:32 -0500
In-Reply-To: <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Nov 2012 17:14:13 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Now that tunnels can be configured via rtnetlink, this device is not mandatory.
> The default is conservative.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>


Although I am in favor of reducing clutter, and we even have to put in special case
code to ignore these stub devices in the Vyatta scripts. Module parameters are bit of a nuisance to deal with, but maybe
the only way for this kind of thing and keep the required ABI.

Not sure if I can fully endorse this. The device may still have uses.
It is still useful for capturing "none of the above" packets
and is used to auto-load module via module aliases.
