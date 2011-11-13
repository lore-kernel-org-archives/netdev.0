From: Simon Chen <simonchennj@gmail.com>
Subject: bonding xmit_policy
Date: Sat, 12 Nov 2011 21:55:42 -0500
Message-ID: <CANj2Ebfj+7R+wCK7jJennBN7_6THJGqs8FWSAPOv7BYYsR=u9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45884 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab1KMCzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 21:55:43 -0500
Received: by gyc15 with SMTP id 15so3994057gyc.19
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 18:55:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

It looks like that there are three entries in xmit_policy (hashing for
deciding egress phy int) for bonded interfaces:

const struct bond_parm_tbl xmit_hashtype_tbl[] = {
{       "layer2",               BOND_XMIT_POLICY_LAYER2},
{       "layer3+4",             BOND_XMIT_POLICY_LAYER34},
{       "layer2+3",             BOND_XMIT_POLICY_LAYER23},
{       NULL,                   -1},
};


We can set the xmit_policy either at module initiation, or later via
/sys. However, this xmit_policy isn't really read anywhere. Are
different policies really implemented?

Thanks.
-Simon
