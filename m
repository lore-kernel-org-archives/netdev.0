From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 12:10:22 +0300
Message-ID: <CAF1J0HNDrqAfWSkdsF7UW=EqJ5yv8hN-uGZi+SRa1F2nYMZWxw@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog106.obsmtp.com ([74.125.245.80]:37623 "HELO
	na3sys010aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751931Ab3FDJKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 05:10:24 -0400
Received: by mail-ob0-f179.google.com with SMTP id xk17so9012372obc.10
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 02:10:23 -0700 (PDT)
In-Reply-To: <OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 11:18 PM, David Stevens <dlstevens@us.ibm.com> wrote:

>> 4. clean up the multi-dest tx code
>
> Everybody likes their own code, of course, but I think the original
> was cleaner. A vxlan_rdst was part of an fdb structure because all
> fdbs require a remote destination, while the clean-up changes that
> to a list which may then be NULL, and in my opinion is notably less
> clean. I don't know the reasoning for that-- perhaps some thread I
> missed?

Maybe this one:
http://thread.gmane.org/gmane.linux.network/271383

> So, I guess I don't see what you're trying to fix here, other than
> preventing snoop updates on static entries, which I agree with.
>
>                                                         +-DLS
>



--
Sincerely yours,
Mike.
