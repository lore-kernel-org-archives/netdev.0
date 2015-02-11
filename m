From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/7] net: Fixes to remote checksum offload and CHECKSUM_PARTIAL
Date: Tue, 10 Feb 2015 23:04:51 -0500
Message-ID: <CAJ3xEMg112cOhwfBS1PX84J7XvOEukNXqGDP5w5H8oZS0EKDfA@mail.gmail.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:60922 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbBKEEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 23:04:52 -0500
Received: by mail-ob0-f179.google.com with SMTP id wp4so1054517obc.10
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 20:04:51 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 7:30 PM, Tom Herbert <therbert@google.com> wrote:
> This patch set fixes a correctness problem with remote checksum
> offload, clarifies the meaning of CHECKSUM_PARTIAL, and allows
> remote checksum offload to set CHECKSUM_PARTIAL instead of
> calling csum_partial and modifying the checksum.

Hi Tom,

Does this series change elements in the RCO basic architecture as you
described it in your LKS [1] slides and/or the IETF draft [2]?

Or.

[1] http://vger.kernel.org/encapsulation_offloads.pdf
[2] https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01
