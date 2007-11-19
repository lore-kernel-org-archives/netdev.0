From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][PKTGEN] Fix double unlock of xfrm_state->lock
Date: Mon, 19 Nov 2007 11:18:18 -0500
Message-ID: <1195489098.4445.113.camel@localhost>
References: <47415B94.1010002@openvz.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:48540 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbXKSQSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 11:18:25 -0500
Received: by py-out-1112.google.com with SMTP id u77so5880639pyb
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 08:18:25 -0800 (PST)
In-Reply-To: <47415B94.1010002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-19-11 at 12:47 +0300, Pavel Emelyanov wrote:
> The pktgen_output_ipsec() function can unlock this lock twice
> due to merged error and plain paths. Remove one of the calls
> to spin_unlock.

Good catch.
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

