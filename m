From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Thu, 10 Apr 2008 11:45:16 -0700
Message-ID: <1207853118.5557.6.camel@dell>
References: <20080410154401.GA14486@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Phil Oester" <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3673 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740AbYDJRuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 13:50:51 -0400
In-Reply-To: <20080410154401.GA14486@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-04-10 at 08:44 -0700, Phil Oester wrote:
> I recently upgraded a Dell Poweredge 1950 from 2.6.21 to 2.6.24, and
> found
> that the onboard Broadcom NetXtreme II nics got probed in the reverse
> order.

I know there is a difference in PCI probing order between 2.4 and 2.6
kernels on x86 machines, but I'm not aware of changes in these 2 recent
2.6 kernels you mentioned above.  Various kernel parameters such as
pci=nosort, pci=bfsort, pci=nobfsort can affect the order.  Are you
using any of these?

