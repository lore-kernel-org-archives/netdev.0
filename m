From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Sat, 13 May 2006 18:13:25 +0200
Message-ID: <20060513161325.GA27805@electric-eye.fr.zoreil.com>
References: <446259A0.8050504@myri.com> <Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com> <20060510231347.GC25334@electric-eye.fr.zoreil.com> <4463CE88.20301@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48560 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932470AbWEMQPb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 May 2006 12:15:31 -0400
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <4463CE88.20301@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <brice@myri.com> :
[...]
> > Return in a middle of a spinlock-intensive function. :o(
> >   
> 
> What do you mean ?

It is preferred for maintenance purpose (hello Mr Morton) to organize
the control flow with a single spin_{lock/unlock} pair: if there is a
branch in the control flow, it ought to be joined again before returning.

-- 
Ueimor
