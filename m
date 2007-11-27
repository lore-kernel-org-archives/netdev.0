From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 4/4] atm/ambassador: kmalloc + memset conversion to kzalloc
Date: Tue, 27 Nov 2007 09:40:39 -0500
Message-ID: <200711271440.lAREedEK011753@cmf.nrl.navy.mil>
References: <alpine.LFD.0.9999.0711260619580.10766@localhost.localdomain>
Reply-To: chas3@users.sourceforge.net
Cc: Joonwoo Park <joonwpark81@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:63290 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbXK0OlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 09:41:22 -0500
Reply-To: chas3@users.sourceforge.net
In-reply-to: <alpine.LFD.0.9999.0711260619580.10766@localhost.localdomain> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <alpine.LFD.0.9999.0711260619580.10766@localhost.localdomain>,"Rober
t P. J. Day" writes:
>> > in any event, i just thought i'd point it out.  if you're absolutely
>> > sure there will never be another call to setup_dev() from somewhere
>> > else, then, yes, it's safe.
>>
>> I understood your opinions. and partially agree with you.
>> But isn't it a unfounded fear?
>
>i don't know, i just thought i'd mention it.  if no one thinks it's an
>issue, it's certainly fine with me.

its very unlikely that setup_dev() is likely to be called from another
code path.  this patch looks fine to me.  i will take it and get it
submitted on the next merge.
