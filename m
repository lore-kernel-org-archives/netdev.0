From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: IPv6 default routes timing out?
Date: Thu, 30 Jul 2009 12:30:58 -0500
Message-ID: <1248975058.7167.28.camel@Maple>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
	 <1248914038.13447.17.camel@merlyn>
	 <87k51q6raq.fsf@shaolin.home.digitalvampire.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roland Dreier <roland@digitalvampire.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f203.google.com ([209.85.216.203]:49300 "EHLO
	mail-px0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbZG3RbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 13:31:01 -0400
Received: by pxi41 with SMTP id 41so450756pxi.33
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 10:31:02 -0700 (PDT)
In-Reply-To: <87k51q6raq.fsf@shaolin.home.digitalvampire.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-30 at 09:58 -0700, Roland Dreier wrote:
> Thanks, I did some more debugging it seems the issue is in the
> router's (openbsd) wireless driver -- it thinks it is broadcasting
> router advertisements but they aren't making it to the laptop.

Could it be that there's something buggy in the laptop wireless driver
or hardware re filtering of multicast packets at the L2 level? 

  --  John

