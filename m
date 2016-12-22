From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering
 mode
Date: Wed, 21 Dec 2016 17:27:59 -0800
Message-ID: <20161221172759.1bc0d0dd@xeon-e3>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
        <1481179898-10668-2-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36698 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbcLVB2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:28:07 -0500
Received: by mail-pf0-f174.google.com with SMTP id 189so36871189pfz.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 17:28:07 -0800 (PST)
In-Reply-To: <1481179898-10668-2-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Dec 2016 14:51:38 +0800
Mao Wenan <maowenan@huawei.com> wrote:

> This patch provides one way to set/unset IXGBE NIC TX and RX
> relax ordering mode, which can be set by ethtool.
> Relax ordering is one mode of 82599 NIC, to enable this mode
> can enhance the performance for some cpu architecure.

Then it should be done by CPU architecture specific quirks (preferably in PCI layer)
so that all users get the option without having to do manual intervention.

> example:
> ethtool -s enp1s0f0 relaxorder off
> ethtool -s enp1s0f0 relaxorder on

Doing it via ethtool is a developer API (for testing) not something that makes
sense in production.
