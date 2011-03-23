From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: can: c_can: TX delivery
Date: Wed, 23 Mar 2011 16:49:25 +0100
Message-ID: <20110323154925.GF346@e-circ.dyndns.org>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
 <20110323085340.GC346@e-circ.dyndns.org>
 <ff5ade24e148af2e46832e5a64444d05.squirrel@www2.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bhupesh.sharma@st.com, wg@grandegger.com, b.spranger@linutronix.de,
	netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:24243 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab1CWPta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 11:49:30 -0400
Content-Disposition: inline
In-Reply-To: <ff5ade24e148af2e46832e5a64444d05.squirrel@www2.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2011 at 04:32:31PM +0100, Jan Altenberg wrote:
> Hi,
> 
> > I split your 2 questions in 2 replies.
> 
> Thanks :)
> 
> > not sure if I made my point.  Note that this will eliminate the need
> > for explicit wrap-around.  It's done implicitely.
> 
> Hmmm, I double-checked the datasheet, which gives the following statement:
> "The receive/transmit priority for the Message Objects is attached to
> the message number.  Message Object 1 has the highest priority, while
> Message Object 32 has the lowest priority. If more than one
> transmission request is pending, they are serviced due to the priority
> of the corresponding Message Object."

With its predecessor (I used it as IP inside infineon CPU's), this was also
true. But I _think_ that object 17 could send before object 16 if its identifier
is lower.
So, me too wait for Bhupesh ...

> I'm quite new to Bosch's c_can, so maybe Bhupesh can give some feedback
> (or beat me for causing some confusion ;-)).
> 
> Sorry for the confusion!
>         Jan
> 
> 
