From: dormando <dormando@rydia.net>
Subject: Re: IPv6 kernel warning
Date: Fri, 11 Oct 2013 11:15:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1310111111280.7285@dtop>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk> <20130920160830.GA4241@marquez.int.rhx> <CAK6E8=eNFG0fic+NYeQBjEoUQMeZKSAT3LU0JSQyE-4i_cDaZQ@mail.gmail.com> <alpine.DEB.2.02.1310071111240.17658@dtop> <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
 <alpine.DEB.2.02.1310071256190.17658@dtop> <CAK6E8=d_O+HHTKb37zGKxpU8E0tTUL6m77g_o6a7ASEiJfXSkw@mail.gmail.com> <alpine.DEB.2.02.1310081123230.21359@dtop> <CAK6E8=d5VWMoOpDhZR4WaU6V6NJ9YSvJr=mm=rYNir0z644H=A@mail.gmail.com>
 <CAK6E8=fZnQXNjO_dh7sALOfsa=BL7qKzzZkzQrRtX3k9ehBZPA@mail.gmail.com> <alpine.DEB.2.02.1310091147340.5669@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michele Baldessari <michele@acksyn.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:50825 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396Ab3JKSPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Oct 2013 14:15:49 -0400
In-Reply-To: <alpine.DEB.2.02.1310091147340.5669@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 9 Oct 2013, dormando wrote:

> > > >> >>
> > > >> >
> > > >> > Should I apply this and see if the warning stops?
> > Hi Dormando,
> >
> > Could you try this patch to make sure it fixes the warning (with
> > sysctl net.ipv4.early_retrans=3)?
>
> It's now running on one machine, with early_retrans=3. Will have to give
> it 24 hours to confirm.
>

Almost 48 hours, early_retrans=3, no warnings! (or crashes...)

Good catch :)
