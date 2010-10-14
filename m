From: jamal <hadi@cyberus.ca>
Subject: Re: xfrm by MARK: tcp problems when mark for in and out differ
Date: Thu, 14 Oct 2010 09:14:58 -0400
Message-ID: <1287062098.3756.9.camel@bigi>
References: <201010131557.06588.lists@egidy.de>
	 <1287057741.3756.6.camel@bigi>  <201010141501.59145.lists@egidy.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57295 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab0JNNPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 09:15:01 -0400
Received: by iwn41 with SMTP id 41so817157iwn.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 06:15:00 -0700 (PDT)
In-Reply-To: <201010141501.59145.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerd,

On Thu, 2010-10-14 at 15:01 +0200, Gerd v. Egidy wrote:

> this is wrong, the value in fl->mark is always 0. I must have confused some 
> data in my debug printks.
>
> So it seems like the fl->mark is never initialized with the packet mark in the 
> first place. What would be the correct stage in the kernel network stack to do 
> that?

Can you try a simple setup without xfrm/ipsec and see if this reverse
path works? Was there a kernel where it worked?

cheers,
jamal

