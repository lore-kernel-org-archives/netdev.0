From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Sun, 3 Dec 2006 23:05:15 +0100
Message-ID: <200612032305.16567.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <1165173618.3233.243.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:611 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1760137AbWLCWFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 17:05:33 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4191325nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 14:05:31 -0800 (PST)
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1165173618.3233.243.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 December 2006 20:20, Arjan van de Ven wrote:
> this open_count thing smells fishy to me; what are the locking rules for
> it? What guarantees that the readers of it don't get the value changed
> underneath them between looking at the value and doing whatever action
> depends on it's value ?

Good point, a race condition could indeed occur in the only reader
that sends the signal to the userspace through the input device.
I'll fix this immediately.

Thanks,

Ivo
