From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: various 802.3ad fixes
Date: Mon, 26 Jan 2015 19:49:24 -0500
Message-ID: <20150127004924.GA13164@gospo.home.greyhouse.net>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:41273 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbbA0Atd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:49:33 -0500
Received: by mail-qg0-f43.google.com with SMTP id e89so9673575qgf.2
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 16:49:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2015 at 01:16:56AM -0500, Jonathan Toppins wrote:
> This patch series is a forward porting of patches we (Cumulus) are shipping
> in our 3.2 series kernels. These fixes attempt to make 802.3ad bonding mode
> more predictable in certian state machine transtions in addition to fixing
> 802.3ad bond carrier determination when bonding min_links option is changed.
> Specific notes are contained within each patch.
> 
> For this patch series there are no userspace facing changes, a diff between
> the modinfo output showed no difference. However, there are behavioral
> facing changes, primarily in the bond carrier state. Please make sure to
> review carefully.
> 
> v2:
>  * fixed some style issues
>  * dropped a portion of patch 1 in favor of more testing on my side
> 
> Jonathan Toppins (2):
>   bonding: update bond carrier state when min_links option changes
>   bonding: cleanup and remove dead code
> 
> Satish Ashok (1):
>   bonding: fix LACP PDU not sent on slave port sometimes
> 
> Wilson Kok (2):
>   bonding: fix bond_open() don't always set slave active flag
>   bonding: fix incorrect lacp mux state when agg not active
> 
>  drivers/net/bonding/bond_3ad.c     |   55 +++++++++++++++++++++++++++---------
>  drivers/net/bonding/bond_main.c    |    6 ++--
>  drivers/net/bonding/bond_options.c |    1 +
>  include/net/bond_3ad.h             |    1 -
>  include/net/bonding.h              |    1 +
>  5 files changed, 47 insertions(+), 17 deletions(-)

Great work on this, Jon.

For the series:

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
