From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net-next 4/4] igb: fix last_rx_timestamp usage
Date: Thu, 3 Apr 2014 15:20:52 +0000
Message-ID: <CF62C97F.43F0F%matthew.vick@intel.com>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
 <1396399939-18420-5-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jakub Kicinski <kubakici@wp.pl>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42633 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbaDCP02 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:26:28 -0400
In-Reply-To: <1396399939-18420-5-git-send-email-kubakici@wp.pl>
Content-Language: en-US
Content-ID: <ED2F9D0B778F7548ADDD02AFB78D2CA9@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/14, 5:52 PM, "Jakub Kicinski" <kubakici@wp.pl> wrote:

>last_rx_timestamp should be updated only when rx time stamp is
>read. Also it's only used with NICs that have per-interface time
>stamping resources so it can be moved to adapter structure and
>set in igb_ptp_rx_rgtstamp().
>
>Signed-off-by: Jakub Kicinski <kubakici@wp.pl>

Looks good to me, Jakub. Thanks for doing this work!

Acked-by: Matthew Vick <matthew.vick@intel.com>
