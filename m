From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Simplify MSI interrupt testing
Date: Mon, 13 Sep 2010 23:34:54 -0700
Message-ID: <AANLkTikhxka-HHX+SWMpXHcANZCMzedEz+XyiwmF48AK@mail.gmail.com>
References: <201009131045.40018.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37586 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab0INGey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 02:34:54 -0400
Received: by iwn5 with SMTP id 5so5825112iwn.19
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 23:34:54 -0700 (PDT)
In-Reply-To: <201009131045.40018.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 01:45, Jean Delvare <jdelvare@suse.de> wrote:
> The code is quite convoluted, simplify it. This also avoids calling
> e1000_request_irq() without testing the value it returned, which was
> bad.
>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Bruce Allan <bruce.w.allan@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

FYI - Emil tested this while I was out, and all was good.  Sorry for
the delayed response Jean.
