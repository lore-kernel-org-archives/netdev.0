From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH v2 net] gianfar : Do right check on num_txbdfree
Date: Thu, 26 Feb 2009 16:07:16 -0600
Message-ID: <2acbd3e40902261407w7e92dbe0u4dd008b3e6b239a2@mail.gmail.com>
References: <49A6595A.9000405@arvoo.nl>
	 <20090226.020318.50178027.davem@davemloft.net>
	 <49A66E2D.3060204@arvoo.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Linuxppc-dev@ozlabs.org,
	afleming@freescale.com, netdev@vger.kernel.org
To: Rini van Zetten <rini@arvoo.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:16500 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbZBZWHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 17:07:18 -0500
Received: by yw-out-2324.google.com with SMTP id 5so578277ywh.1
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:07:16 -0800 (PST)
In-Reply-To: <49A66E2D.3060204@arvoo.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 4:25 AM, Rini van Zetten <rini@arvoo.nl> wrote:
> This patch fixes a wrong check on num_txbdfree. It could lead to
> num_txbdfree become nagative.
> Result was that the gianfar stops sending data.
>
> Changes from first version :
> - removed a space between parens (David Millers comment)
> - full email address in signed off line
>
>
> Signed-off-by: Rini van Zetten <rini@arvoo.nl>

Good catch.  Does this solve the bug you reported earlier?

Acked-by: Andy Fleming <afleming@freescale.com>
