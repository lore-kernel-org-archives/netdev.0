From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 13:25:34 +0100
Message-ID: <CAKh2mn473azekf6WWrP4mb0yMwYgurksiJYAVG7DNjikJydffQ@mail.gmail.com>
References: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
	<1348497654-9915-6-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:44259 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669Ab2IZMZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:25:35 -0400
Received: by obbuo13 with SMTP id uo13so460285obb.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 05:25:34 -0700 (PDT)
In-Reply-To: <1348497654-9915-6-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, just spotted this error:


On 24 September 2012 15:40, Steve Glendinning
<steve.glendinning@shawell.net> wrote:
> @@ -1283,6 +1308,9 @@ static struct usb_driver smsc95xx_driver = {
>         .suspend        = usbnet_suspend,
>         .resume         = usbnet_resume,
>         .reset_resume   = usbnet_resume,
> +       .suspend        = smsc95xx_suspend,
> +       .resume         = usbnet_resume,
> +       .reset_resume   = usbnet_resume,
>         .disconnect     = usbnet_disconnect,
>         .disable_hub_initiated_lpm = 1,
>  };

I'm sure we don't need those in there twice, I'll re-submit this patch.

-Steve
