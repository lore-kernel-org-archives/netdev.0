From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
Date: Sat, 16 Mar 2013 19:40:36 +0100
Message-ID: <20130316184036.GE24041@order.stressinduktion.org>
References: <20130316170348.GD24041@order.stressinduktion.org> <DUB002-W54999962E08C0F2E11B4EEDDEE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Derehag <jderehag@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39291 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab3CPSki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 14:40:38 -0400
Content-Disposition: inline
In-Reply-To: <DUB002-W54999962E08C0F2E11B4EEDDEE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 16, 2013 at 05:57:20PM +0000, Jesper Derehag wrote:
> 
> 
> > Date: Sat, 16 Mar 2013 18:03:48 +0100
> > From: hannes@stressinduktion.org
> > To: jderehag@hotmail.com
> > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
> > 
> > On Sat, Mar 16, 2013 at 11:50:50AM +0100, Jesper Derehag wrote:
> > > +	ev->event_data.exit.exit_code = task->exit_code;
> > > +	ev->event_data.exit.exit_signal = task->exit_signal;
> > 
> > Do these already contain meaningful values?
> > 
> 
> I have to admit that they dont.And you are correct, I should add a new event struct specific for the coredump event instead of piggybacking on the exit struct.Will re-submit a patch..

Hm, I am still unsure if such a patch is needed. Couldn't you test for
coredump by inspecting exit_code on PROC_EVENT_EXIT?
