From: Marcel Holtmann <marcel@holtmann.org>
Subject: Useless debug warning "netlink: 16 bytes leftover after parsing
 attributes"
Date: Tue, 18 Oct 2016 07:06:50 +0200
Message-ID: <0756CFFC-5BF7-4685-A1E2-0D88B2898454@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Michal Schmidt <mschmidt@redhat.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:49923 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755038AbcJRFGx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 01:06:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

so lately I am seeing a bunch of these warnings:

netlink: 16 bytes leftover after parsing attributes..

While they give you the process name, they are still useless to track down the message that causes them. I find them even more useless since an updated userspace on an older kernel can trigger the nla_policy warning here. And that updated userspace program is doing nothing wrong by including extra attributes. So what purpose is this warning serving?

Regards

Marcel
