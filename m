From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: dynamically allocated dst_ops
Date: Thu, 30 Oct 2008 07:22:41 +0300
Message-ID: <20081030042241.GA15999@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, containers@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:33918 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbYJ3ETX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 00:19:23 -0400
Received: by nf-out-0910.google.com with SMTP id d3so180249nfc.21
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 21:19:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are bogus and should be implanted into struct net directly.
In garbage collector hook, just use container_of() (once) to get struct net.
->dst_net is useless after that.

I'm going to use this trick for xfrm.

And if someone has ideas on how to overcome header difficulties, please,
submit a patch.
