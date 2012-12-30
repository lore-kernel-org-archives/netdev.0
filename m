From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCHv2 net-next] bridge: respect RFC2863 operational state
Date: Sun, 30 Dec 2012 00:01:37 -0200
Message-ID: <20121230020137.GB2077@obelix.rh>
References: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
 <20121228.152754.707370216340290808.davem@davemloft.net>
 <20121228201522.62a48370@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778Ab2L3CBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 21:01:46 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qBU21dWG002194
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 21:01:45 -0500
Received: from localhost (ovpn-113-70.phx2.redhat.com [10.3.113.70])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qBU21cuv009271
	for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 21:01:39 -0500
Content-Disposition: inline
In-Reply-To: <20121228201522.62a48370@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 08:15:22PM -0800, Stephen Hemminger wrote:
> The bridge link detection should follow the operational state
> of the lower device, rather than the carrier bit. This allows devices
> like tunnels that are controlled by userspace control plane to work
> with bridge STP link management.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---

Although I can't test this right now, it does look good to me.
 
Reviewed-by: Flavio Leitner <fbl@redhat.com>
