From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 0/3] ethtool: Add link down reason reporting
Date: Thu, 22 Jun 2017 14:13:41 +0300
Message-ID: <c30eb6ba-dd73-1bd9-9ceb-40fe2f9e0408@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <20170621084415.4a4b54ac@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0061.outbound.protection.outlook.com ([104.47.1.61]:62784
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752918AbdFVLNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 07:13:50 -0400
In-Reply-To: <20170621084415.4a4b54ac@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ethtool doesn't work well as a monitoring/event interface.
> Maybe this would be better as extended information with the  netlink UP/DOW event.

This API is not meant for monitoring events.
The main use case here is a new interface that's down and won't go up for some reason.
Nothing will magically change until someone fixes the issue, logging the reason as an event on
netdev creation seems less convenient to me.
