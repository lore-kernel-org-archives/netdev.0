From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 4/4] atm/ambassador: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 19:53:19 +0900
Message-ID: <b25c3fa70711260253we514310g2652d40440dc514e@mail.gmail.com>
References: <007f01c8300b$1b89ac40$9c94fea9@jason>
	 <alpine.LFD.0.9999.0711260409110.551@localhost.localdomain>
	 <b25c3fa70711260223w5a15bb1bk4652b3ab8f05c40c@mail.gmail.com>
	 <alpine.LFD.0.9999.0711260523420.12603@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-kernel@vger.kernel.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:64078 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbXKZKxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:53:19 -0500
Received: by rv-out-0910.google.com with SMTP id k20so482218rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 02:53:19 -0800 (PST)
In-Reply-To: <alpine.LFD.0.9999.0711260523420.12603@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/26, Robert P. J. Day <rpjday@crashcourse.ca>:
> i realized that.  but all you can say is that only amb_init() calls
> setup_dev() *currently*.  when you're not looking, someone else might
> (for whatever reason) call setup_dev() from elsewhere, and *that* call
> might not zero that memory area.
>
> IMHO, the only safe transforms of kmalloc+memset -> kzalloc are those
> in which the flow of control is unmistakable and invariant.  splitting
> that across a function call seems like a dangerous thing to do.
> (except, of course, in the case, where the kzalloc() is added inside
> the function -- then all callers are entitled to simplify *their*
> code.  but that's different.)
>
> in any event, i just thought i'd point it out.  if you're absolutely
> sure there will never be another call to setup_dev() from somewhere
> else, then, yes, it's safe.
>

I understood your opinions. and partially agree with you.
But isn't it a unfounded fear?

Thanks
Joonwoo
