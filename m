From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2] openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD
Date: Thu, 16 Mar 2017 11:46:05 -0700
Message-ID: <CAPWQB7FifWMM=bmUf0KhnFKKZVkq04w=-QXf25tmT29pDJTHBA@mail.gmail.com>
References: <1b8ba07efdee3db310d4504462924565684ebd64.1489677257.git.kriskend@linux.vnet.ibm.com>
 <1489679488-18874-1-git-send-email-kriskend@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, seroyer@linux.vnet.ibm.com,
        adreznec@linux.vnet.ibm.com
To: Kris Murphy <kriskend@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:53938 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbdCPSqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:46:31 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id BECF641C08E
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 19:46:28 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id fn7_9Owao9s1 for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 19:46:27 +0100 (CET)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1856941C099
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 19:46:26 +0100 (CET)
Received: by mail-qk0-f178.google.com with SMTP id p64so47256143qke.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:46:26 -0700 (PDT)
In-Reply-To: <1489679488-18874-1-git-send-email-kriskend@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16 March 2017 at 08:51, Kris Murphy <kriskend@linux.vnet.ibm.com> wrote:
> Added a case for OVS_TUNNEL_KEY_ATTR_PAD to the switch statement
> in ip_tun_from_nlattr in order to prevent the default case
> returning an error.
>
> Fixes: b46f6ded906e ("libnl: nla_put_be64(): align on a 64-bit area")
> Signed-off-by: Kris Murphy <kriskend@linux.vnet.ibm.com>

Thanks for the fix. In future please also place the target tree (in
this case 'net') in the subject line.

Acked-by: Joe Stringer <joe@ovn.org>
