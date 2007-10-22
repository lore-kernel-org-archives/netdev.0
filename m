From: wit <is01kzh@gmail.com>
Subject: Re: about multiple network interface
Date: Mon, 22 Oct 2007 10:09:38 +0800
Message-ID: <105610bf0710211909r6ab2b63fo8a4f67eba6c05bc7@mail.gmail.com>
References: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com>
	 <20071018132836.GA15906@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:61743 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbXJVCJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 22:09:39 -0400
Received: by nz-out-0506.google.com with SMTP id s18so295100nze
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 19:09:38 -0700 (PDT)
In-Reply-To: <20071018132836.GA15906@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks very much

But this does work until I add a ifcfg-eth0 in
sysconfig/network-script with the following content:
DEVICE=eth0
ONBOOT=yes

What is the relationship between these two files? And sometimes, I see
this message:
Bringing up interface eth0:  e100 device does not seem to be present, delaying e
th0 initialization.
Why??

2007/10/18, Evgeniy Polyakov <johnpol@2ka.mipt.ru>:
> On Thu, Oct 18, 2007 at 09:06:40PM +0800, wit (is01kzh@gmail.com) wrote:
> > Hi all,
> >
> >    Sorry, I don't know if this is the right mail list. I got the
> > following question:
> >    I have a e100 card and a e1000 card. Whenever I boot the system, I
> > found the eth0 matches the e1000 card, and the eth2 matches the other.
> > How can I force the eth0 to match the e100 card and the eth2 to match
> > e1000?
>
> Hi.
>
> Check your /etc/modprobe.conf and put there
>
> alias eth0 e100
> alias eth2 e1000
>
>
> --
>         Evgeniy Polyakov
>
