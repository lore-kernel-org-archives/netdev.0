From: Dirk <biecie547@gmail.com>
Subject: Re: [RFT] r8169 changes against 2.6.23-rc3
Date: Mon, 20 Aug 2007 10:34:45 +0200
Message-ID: <88ab4080708200134y2c05173aia5dd4e8b1a5a5712@mail.gmail.com>
References: <20070818100701.GA20703@electric-eye.fr.zoreil.com>
	 <46C7ADD6.5080707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:16450 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbXHTIeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 04:34:46 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1180102wxd
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 01:34:46 -0700 (PDT)
In-Reply-To: <46C7ADD6.5080707@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/19/07, Bruce Cole <bacole@gmail.com> wrote:
> So it seems that when the driver tries to queue a packet while the
> controller is busy processing the queue, the newly queued packet does
> not get noticed by the controller (until further packet activity occurs).
> Perhaps there is a problem with the memory barriers when adding to the
> TX queue, but I'm a newbie on linux kernel memory barriers.

One thing I noticed a while ago (march) is that floodpinging (ping -f)
the r8169 host from an external system also increases performance
without changing code.

My original post about the problem:
http://marc.info/?l=linux-netdev&m=117207362010321&w=2

I ended up (until now perhaps :-) with disabling the onboard nic and
adding an e1000 card.


Kind regards,
Dirk
