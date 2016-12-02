From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool v5 0/2]  Adding downshift support to ethtool
Date: Fri, 2 Dec 2016 15:24:16 -0500
Message-ID: <20161202202416.GF31657@tuxdriver.com>
References: <1479977811-5603-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59276 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbcLBUaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:30:17 -0500
Content-Disposition: inline
In-Reply-To: <1479977811-5603-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 09:56:49AM +0100, Allan W. Nielsen wrote:
> (downshift feature is applied in the net-next tree - d3c19c0a72)
> 
> This series adds support for downshift (using phy-tunables).
> 
> Downshifting can either be turned on/off, or it can be configured to a
> specifc count. "count" is optional.
> 
> Change set:
> v1:
> - Initial version of set/get phy tunable with downshift feature.
> v2:
> - (ethtool) Syntax is changed from "--set-phy-tunable downshift on|off|%d"
>   to "--set-phy-tunable [downshift on|off [count N]]" - as requested by
>   Andrew.
> v3:
> - Fixed Spelling in "ethtool-copy.h:sync with net" 
> - Fixed "if send_ioctl() returns an error, print the error message and then
>   still print th value of count".
> v4:
> - Fixing spelling in the example included in the commit message
> - Improve the description in the man-page
> v5:
> - re-sync ethtool.h from the net-next tree.
> 
> 
> Allan W. Nielsen (1):
>   ethtool-copy.h:sync with net-next
> 
> Raju Lakkaraju (1):
>   Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
>     downshift
> 
>  ethtool-copy.h |  21 +++++++--
>  ethtool.8.in   |  40 ++++++++++++++++
>  ethtool.c      | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 202 insertions(+), 3 deletions(-)
> 
> -- 
> 2.7.3

Merged.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
