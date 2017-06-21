From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Wed, 21 Jun 2017 08:43:17 -0700
Message-ID: <20170621084317.45879939@xeon-e3>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
        <1498050286-17141-2-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35916 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdFUQjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:39:31 -0400
Received: by mail-pf0-f176.google.com with SMTP id q86so3371534pfl.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 09:39:25 -0700 (PDT)
In-Reply-To: <1498050286-17141-2-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 16:04:44 +0300
Gal Pressman <galp@mellanox.com> wrote:

> +
> +enum {
> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
> +	ETHTOOL_LINK_AN_FAILED, /* Auto negotiation failed */
> +	ETHTOOL_LINK_TRAINING_FAILED, /* Link training failed */
> +	ETHTOOL_LINK_RMT_FAULT, /* Remote fault indication */
> +	ETHTOOL_LINK_BAD_SIGNAL_INTEGRITY, /* Bad signal integrity */
> +	ETHTOOL_LINK_CABLE_MISMATCH, /* Cable protocol mismatch */
> +	ETHTOOL_LINK_INTERNAL_ERR, /* Internal error */
> +	ETHTOOL_LINK_CABLE_UNPLUGGED, /* Cable unplugged */
> +	ETHTOOL_LINK_UNSUPP_MODULE, /* Unsupported module */
> +	ETHTOOL_LINK_I2C_BUS_ERR, /* I2C bus error */
> +	ETHTOOL_LINK_UNSUPP_EEPROM, /* Unsupported EEPROM */
> +	ETHTOOL_LINK_OVERTEMP, /* Over temperature */
> +	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
> +	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */
> +
> +	ETHTOOL_LINK_REASONS_COUNT
> +};

Any enumerated list is going to get changed too often.
Could the API just return a string?
