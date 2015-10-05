From: Thomas Graf <tgraf@suug.ch>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 14:28:30 +0200
Message-ID: <20151005122830.GD5490@pox.localdomain>
References: <20150930135141.GF2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eladr@mellanox.com,
	idosch@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33887 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbJEQW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 12:22:59 -0400
Received: by wicfx3 with SMTP id fx3so128192880wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 09:22:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150930135141.GF2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/15 at 03:51pm, Jiri Pirko wrote:
> 2) generic Netlink (genl) interface. Easy to put metadata in, including the
> device identificator (pci address). User then can use nlmon in order to
> be able to use wireshark to see the netlink messages.
> 
> Looks like 2) might be viable, well-defined, generic interface to carry
> this info. What do you think? Does this make sense?

+1 since we already have nlmon and Netlink is our standard
control plane protocol.
