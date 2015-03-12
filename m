From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: MTU of bridge after deleting an interface
Date: Thu, 12 Mar 2015 16:18:19 -0700
Message-ID: <CAJieiUhEGkxZ0a5kstobgNpP31xKrT+yLLBm4L1QrB1iHQgWJA@mail.gmail.com>
References: <ebf95dd7-9166-43d5-9919-22f2cd654ef6@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33061 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbbCLXSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:18:20 -0400
Received: by padet14 with SMTP id et14so24392819pad.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:18:20 -0700 (PDT)
In-Reply-To: <ebf95dd7-9166-43d5-9919-22f2cd654ef6@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 3:37 PM, Venkat Venkatsubra
<venkat.x.venkatsubra@oracle.com> wrote:
> Hello All,
>
> When adding an interface the bridge interface's MTU is set to the
> minimum of all the interfaces. Call to dev_set_mtu(br->dev, br_min_mtu(br))
> in br_add_if() achieves that. But when deleting an interface from the bridge
> the MTU is not reset again to the minimum of the current set of interfaces.
> Is there a reason it is that way ?
>
> If not I could send a patch that resets the MTU with a call to
> dev_set_mtu(br->dev, br_min_mtu(br)) in br_del_if().
>
seems like the right thing to do. you should submit a patch.
