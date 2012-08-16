From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 001/001] smsc95xx: Fix hard_header_len
Date: Thu, 16 Aug 2012 10:57:51 +0100
Message-ID: <CAKh2mn4pK-8=OVkahSZ8VWpX9Va=qCDQUdOONK1FZ75Fbk0Mdg@mail.gmail.com>
References: <1345060138-5629-1-git-send-email-jimbob.betts@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: JamesBetts <jimbob.betts@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40327 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab2HPJ5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 05:57:52 -0400
Received: by obbuo13 with SMTP id uo13so3455542obb.19
        for <netdev@vger.kernel.org>; Thu, 16 Aug 2012 02:57:52 -0700 (PDT)
In-Reply-To: <1345060138-5629-1-git-send-email-jimbob.betts@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi James,

Thanks for spotting this, I don't think I've ever tested this device with IMQ.

> -       dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
> -       dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> +       dev->net->needed_headroom = SMSC95XX_TX_OVERHEAD_CSUM;
> +       dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len +
> dev->net->needed_headroom;

I'm unsure what we *should* be setting hard_header_len and
needed_headroom to.  David?

Thanks,
--
Steve Glendinning
