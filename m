From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: force user to set port value
Date: Wed, 15 May 2013 14:47:30 -0700 (PDT)
Message-ID: <20130515.144730.888918410336115705.davem@davemloft.net>
References: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<20130515.132213.120685330795916926.davem@davemloft.net>
	<20130515134818.18b2c710@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab3EOVrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:47:32 -0400
In-Reply-To: <20130515134818.18b2c710@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen, this doesn't work either.

You're breaking people's scripts.

Even worse, you're breaking things, and your error message doesn't
even tell the user how to get the previous behavior.  You're telling
them how to get new behavior, which they probably don't give a
crap about.  They want their existing stuff to work.

Stop being in denial, we are stuck with the old port number default.

Again, we cannot change this default without breaking something which
we've already deployed to users.

If this port number issue was so important, we should have done
something about it when we integrated vxlan.  But we didn't, so we
have to live with the consequences.

Now is far too late to change the default.
