From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/12] Make and configuration files.
Date: Tue, 27 Dec 2016 08:15:06 -0800
Message-ID: <1482855306.1876.1.camel@perches.com>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: David VomLehn <vomlehn@texas.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0201.hostedemail.com ([216.40.44.201]:58084 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932461AbcL0QRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:17:47 -0500
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave08.hostedemail.com (Postfix) with ESMTP id C5C7A21187A
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2016 16:17:10 +0000 (UTC)
In-Reply-To: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-27 at 05:17 -0800, David VomLehn wrote:
> Patches to create the make and configuration files.

A few small things about this patch series that adds a
new driver:

These should be sent with a cover letter [0/N] so that
the reason this series is useful can be added to the
merge log.

Patch 1 will not build if CONFIG_AQTION is enabled.
Patch 1/12 should be reordered to be patch 12/12 and
all the other patches moved up appropriately.

The patches should ave a subject prefix of "AQtion: " so
the generic titles are recognizable.
