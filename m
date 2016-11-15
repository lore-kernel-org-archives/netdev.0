From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v3 0/2] Adding downshift support to ethtool
Date: Tue, 15 Nov 2016 11:21:25 +0100
Message-ID: <1479205287-27940-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0087.outbound.protection.outlook.com ([104.47.41.87]:43448
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965840AbcKOKVi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 05:21:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This is a follow-up on the v2 patch series.

Following is updated:

- Spelling
- consistent spaces
- error handling of send_ioctl()

Old cover letters included below.

Please review.

Best regards
Allan and Raju


Raju Lakkaraju (2):
  ethtool-copy.h:sync with net
  Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
    downshift

 ethtool-copy.h |  18 +++++++-
 ethtool.8.in   |  39 ++++++++++++++++
 ethtool.c      | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 200 insertions(+), 1 deletion(-)

> From c235004654ee0212b6cf6ca7af14eb6ef8a04dee Mon Sep 17 00:00:00 2001
> From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
> Date: Mon, 14 Nov 2016 10:22:03 +0100
> Subject: [PATCH ethtool v2 0/2] Adding downshift support to ethtool
> 
> This is a follow-up on the patch series posted at Fri, 4 Nov 2016 11:27:31 +0100
> (old cover letter included below).
> 
> The following is changed/added/addressed:
> - Syntax is changed from "--set-phy-tunable downshift on|off|%d" to
>   "--set-phy-tunable [downshift on|off [count N]]" - as requested by Andrew.
> - Short description of downshifting is added to the man page.
>
> Old cover letter:
> > From 5d926ca56f13e283aaa98e820d4720305be4da8f Mon Sep 17 00:00:00 2001
> > From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
> > Date: Fri, 4 Nov 2016 11:27:31 +0100
> > Subject: [PATCH ethtool 0/2] Adding downshift support to ethtool
> > 
> > Hi All,
> > 
> > This patch implements for set/get downshifting.
> > 
> > Downshifting can either be turned on/off, or it can be configured to a
> > specifc count.
> > 
> > If no "count" are provided, then it is up to the individual PHY driver to
> > configure a default count.

-- 
2.7.3
