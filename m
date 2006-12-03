From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Sun, 3 Dec 2006 23:03:20 +0100
Message-ID: <200612032303.21293.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <1165173482.3233.240.camel@laptopd505.fenrus.org>
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
Received: from nf-out-0910.google.com ([64.233.182.191]:10591 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1760133AbWLCWDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 17:03:38 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4190941nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 14:03:36 -0800 (PST)
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1165173482.3233.240.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 December 2006 20:18, Arjan van de Ven wrote:
> On Sun, 2006-12-03 at 19:36 +0100, Ivo van Doorn wrote:
> > +
> > +       down(&master->key_sem);
> > + 
> 
> Hi,
> 
> this one seems to be used as a mutex only, please consider using a mutex
> instead, as is the default for new code since 2.6.16 or so....

It was indeed intended to be a mutex, I had however missed
the presence of the mutex header in the kernel.
Will fix this immediately.

Thanks,

Ivo
