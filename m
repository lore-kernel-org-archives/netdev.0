From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2] net: Generalize ndo_gso_check tondo_features_check
Date: Thu, 25 Dec 2014 03:29:59 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EDB4FC@RTITMBSV03.realtek.com.tw>
References: <1419403046-43165-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Joe Stringer <joestringer@nicira.com>,
	Eric Dumazet <edumazet@google.com>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:40673 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbaLYDaO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 22:30:14 -0500
In-Reply-To: <1419403046-43165-1-git-send-email-jesse@nicira.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Jesse Gross [mailto:jesse@nicira.com] 
> Sent: Wednesday, December 24, 2014 2:37 PM
[...]
> GSO isn't the only offload feature with restrictions that
> potentially can't be expressed with the current features mechanism.
> Checksum is another although it's a general issue that could in
> theory apply to anything. Even if it may be possible to
> implement these restrictions in other ways, it can result in
> duplicate code or inefficient per-packet behavior.
> 
> This generalizes ndo_gso_check so that drivers can remove any
> features that don't make sense for a given packet, similar to
> netif_skb_features(). It also converts existing driver
> restrictions to the new format, completing the work that was
> done to support tunnel protocols since the issues apply to
> checksums as well.
> 
> By actually removing features from the set that are used to do
> offloading, it solves another problem with the existing
> interface. In these cases, GSO would run with the original set
> of features and not do anything because it appears that
> segmentation is not required.
> 
> CC: Tom Herbert <therbert@google.com>
> CC: Joe Stringer <joestringer@nicira.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Hayes Wang <hayeswang@realtek.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Acked-by:  Tom Herbert <therbert@google.com>
> Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")
> ---
> v2: Rebase
>     Drop overzealous use of netdev_intersect_features()

Tested-by: Hayes Wang <hayeswang@realtek.com>
