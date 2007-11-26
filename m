From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 4/4] atm/ambassador: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 19:23:48 +0900
Message-ID: <b25c3fa70711260223w5a15bb1bk4652b3ab8f05c40c@mail.gmail.com>
References: <007f01c8300b$1b89ac40$9c94fea9@jason>
	 <alpine.LFD.0.9999.0711260409110.551@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-kernel@vger.kernel.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:16126 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbXKZKXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:23:49 -0500
Received: by rv-out-0910.google.com with SMTP id k20so476417rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 02:23:48 -0800 (PST)
In-Reply-To: <alpine.LFD.0.9999.0711260409110.551@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/26, Robert P. J. Day <rpjday@crashcourse.ca>:
> i'm not sure the above is a safe thing to do, as you're zeroing that
> area, then making a function call and assuming, upon entry to the
> function call, that the caller has done the right thing.  i don't see
> how you can count on that, depending on who else might want to call
> that routine and whether they get sloppy about it.  unless you're
> prepared to guarantee that there will never be another call to
> setup_dev() from elsewhere.
>

Thanks for your response.
But setup_dev is static function and only amb_init calls it.
IMO it's safe.

Thanks.
Joonwoo
