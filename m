From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] vxlan: force user to set port value
Date: Wed, 15 May 2013 15:19:44 -0700
Message-ID: <20130515151944.6ae1e03a@nehalam.linuxnetplumber.net>
References: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<20130515.132213.120685330795916926.davem@davemloft.net>
	<20130515134818.18b2c710@nehalam.linuxnetplumber.net>
	<20130515.144730.888918410336115705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:62401 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab3EOWTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 18:19:48 -0400
Received: by mail-pa0-f45.google.com with SMTP id lj1so1917130pab.4
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:19:47 -0700 (PDT)
In-Reply-To: <20130515.144730.888918410336115705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 May 2013 14:47:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Stephen, this doesn't work either.
> 
> You're breaking people's scripts.
> 
> Even worse, you're breaking things, and your error message doesn't
> even tell the user how to get the previous behavior.  You're telling
> them how to get new behavior, which they probably don't give a
> crap about.  They want their existing stuff to work.
> 
> Stop being in denial, we are stuck with the old port number default.
> 
> Again, we cannot change this default without breaking something which
> we've already deployed to users.
> 
> If this port number issue was so important, we should have done
> something about it when we integrated vxlan.  But we didn't, so we
> have to live with the consequences.
> 
> Now is far too late to change the default.


I relented slightly and turned it into a nag, the scripts will still
work but they will be noisy.
