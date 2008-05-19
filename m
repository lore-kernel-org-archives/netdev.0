From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 19 May 2008 11:27:50 -0400
Message-ID: <8bd0f97a0805190827qe5ae0a3r44c2067be76f41d9@mail.gmail.com>
References: <20080515170728.GA3176@PTXN0038.genpitfi01.og.ge.com>
	 <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael.Hennerich@analog.com,
	"Bill Gatliff" <bgat@billgatliff.com>, netdev@vger.kernel.org,
	ian.saturley@smsc.com, "Bahadir Balban" <Bahadir.Balban@arm.com>,
	"Dustin Mcintire" <dustin@sensoria.com>, catalin.marinas@arm.com,
	uclinux-dist-devel@blackfin.uclinux.org
To: "Steve Glendinning" <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:37097 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629AbYESP1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 11:27:51 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1381029wfd.4
        for <netdev@vger.kernel.org>; Mon, 19 May 2008 08:27:50 -0700 (PDT)
In-Reply-To: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2008 at 8:34 AM, Steve Glendinning
<steve.glendinning@smsc.com> wrote:
> +++ b/drivers/net/smsc911x.c
> + * History:
> + *   05/05/2005 bahadir.balban@arm.com
> + *     - Transition to linux coding style
> + *     - Platform driver and module interface

i thought we were against this sort of changelog stuff in files.  let
the scm take care of the changelog.

> +static int smsc911x_init(struct net_device *dev)
> +static int smsc911x_drv_probe(struct platform_device *pdev)

missing __devinit

> +static int smsc911x_drv_remove(struct platform_device *pdev)

missing __devexit

> +static struct platform_driver smsc911x_driver = {
> +       .probe = smsc911x_drv_probe,
> +       .remove = smsc911x_drv_remove,
> +       .driver = {
> +               .name = SMSC_CHIPNAME,
> +       },
> +};

no suspend/resume ? :/
-mike
