From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Wed, 2 May 2007 14:03:54 -0400
Message-ID: <9e246b4d0705021103o28a7dd02t7dc9021a1651c8f8@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
	 <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
	 <20070501204721.GB19212@electric-eye.fr.zoreil.com>
	 <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com>
	 <20070501211754.GB17225@electric-eye.fr.zoreil.com>
	 <9e246b4d0705021038q458ab32r1c4f7431e7bd0f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:40946 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767030AbXEBSEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 14:04:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so204239wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 11:04:00 -0700 (PDT)
In-Reply-To: <9e246b4d0705021038q458ab32r1c4f7431e7bd0f1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/2/07, Tim Durack <tdurack@gmail.com> wrote:
> > > Yup. Works fine. The randomly changing interface order is proving to
> > > be a challenge!
> >
> > udev should be your friend to do a BUS/ID based rename.

Okay, the udev workaround isn't too painful.

Would be great if I could do something like
ATTRS{address}="00:30:18:ab:cd:ef" and have that force the mac during
initialisation.

Tim:>
