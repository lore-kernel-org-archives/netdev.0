From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next-for-3.13 2/2] iplink_bond: add support
 for displaying bond slave attributes
Date: Mon, 10 Feb 2014 12:53:22 -0800
Message-ID: <20140210125322.1535efc5@nehalam.linuxnetplumber.net>
References: <20140210081156.787D5E5697@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36897 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbaBJUx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 15:53:28 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so6685076pab.17
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 12:53:28 -0800 (PST)
In-Reply-To: <20140210081156.787D5E5697@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Feb 2014 09:11:56 +0100 (CET)
Michal Kubecek <mkubecek@suse.cz> wrote:

> +static const char *slave_state_tbl[] = {
> +	"active",
> +	"backup",
> +	NULL
> +};
> +
> +static const char *slave_mii_status_tbl[] = {
> +	"up",
> +	"going_down",
> +	"down",
> +	"going_back",
> +	NULL,
> +};
> +

Is there some correlation of these states to values in a header file.
Something like

static const char *slave_mii_status_tbl[] = {
	[BOND_LINK_UP] = "active",
	[BOND_LINK_FAIL] = "fail",
	[BOND_LINK_DOWN] = "down",
	[BOND_LINK_BACK] = "back",
};


And don't use null terminated arrays, use ARRAY_SIZE() instead.
	
