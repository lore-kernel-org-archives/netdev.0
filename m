From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Thu, 3 Nov 2016 09:02:49 +0200
Message-ID: <CAJ3xEMjndyD3WofZN6MvckEE9iK5SWdKcKf7=HqwXTsGhiu+bw@mail.gmail.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34165 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbcKCHCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 03:02:51 -0400
Received: by mail-oi0-f65.google.com with SMTP id 62so5071993oif.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 00:02:50 -0700 (PDT)
In-Reply-To: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2016 at 5:35 PM, Gal Pressman <galp@mellanox.com> wrote:

> In some cases such as virtual machines and multi functions (SR-IOV), the actual
> bandwidth exposed for each machine is not accurately shown in ethtool.

You mean that if you rate-limit a VF from the host they will be able
to actually query that
and report it to their OS?
