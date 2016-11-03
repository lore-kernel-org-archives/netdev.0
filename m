From: Gal Pressman <galp.dev@gmail.com>
Subject: Re: [RFC PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Thu, 3 Nov 2016 15:24:32 +0200
Message-ID: <25b7fce6-49f9-bd54-5c12-c72298d107c1@gmail.com>
References: <1477363849-36517-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roees@mellanox.com, aviadr@mellanox.com,
        dustin@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        davem@davemloft.net, linville@tuxdriver.com, saeedm@mellanox.com,
        galp@mellanox.com, netdev@vger.kernel.org, odedw@mellanox.com,
        ariela@mellanox.com, Yuval.Mintz@qlogic.com, tzahio@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36408 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbcKCNYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:24:40 -0400
Received: by mail-wm0-f41.google.com with SMTP id p190so333282633wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:24:39 -0700 (PDT)
In-Reply-To: <1477363849-36517-1-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/10/2016 05:50, Vidya Sagar Ravipati wrote:
> SET FEC option:
> root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto] autoneg [off | on]
> 
> Encoding: Types of encoding
> Off    :  Turning off any encoding
> RS     :  enforcing RS-FEC encoding on supported speeds
> BaseR  :  enforcing Base R encoding on supported speeds
> Auto   :  Default FEC settings  for  divers , and would represent

divers? :)

>           asking the hardware to essentially go into a best effort mode.
> 
> Here are a few examples of what we would expect if encoding=auto:
> - if autoneg is on, we are  expecting FEC to be negotiated as on or off
>   as long as protocol supports it
> - if the hardware is capable of detecting the FEC encoding on it's
>       receiver it will reconfigure its encoder to match
> - in absence of the above, the configuration would be set to IEEE
>   defaults.

Not sure I follow, why do we need an autoneg option if encoding type can be set to auto?
