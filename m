From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: e1000e max frame calculation
Date: Mon, 6 Apr 2015 20:47:13 -0700 (PDT)
Message-ID: <alpine.NEB.2.11.1504062043320.2726@chris.i8u.org>
References: <5522B685.2030104@cchtml.com> <5522FE84.6030104@cchtml.com> <55231425.4010405@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Michael Cronenworth <mike@cchtml.com>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:26784
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbbDGDrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 23:47:15 -0400
In-Reply-To: <55231425.4010405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Apr 2015, Alexander Duyck wrote:

> The e1000e pch parts seem very limited in terms of their jumbo frames 
> support.  It looks like the first pch part only supported 4K, and in the case 
> of the later generations I only see support for a 9018 jumbo frame listed in 
> the datasheet.  I suspect this is why that is set as the limit in the driver. 
> The question at this point is if 9018 is the limit, why is it the limit and 
> is there any wiggle room to it.

It's a limit that was told to us by the HW group for the 82579.
