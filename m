From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought
	up
Date: Thu, 25 Jan 2007 11:26:16 -0500
Message-ID: <1169742376.14349.7.camel@localhost.localdomain>
References: <1169707854.10593.41.camel@dv>
	 <a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
	 <20070125135033.7d7d7baf@griffin.suse.cz>
	 <200701250905.33129.gene.heskett@verizon.net>
	 <45B8CE6E.1030508@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gene Heskett <gene.heskett@verizon.net>,
	bcm43xx-dev@lists.berlios.de, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030308AbXAYQ2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 11:28:55 -0500
In-Reply-To: <45B8CE6E.1030508@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-25 at 09:36 -0600, Larry Finger wrote:
> Gene Heskett wrote:
> > On Thursday 25 January 2007 07:50, Jiri Benc wrote:
> >> On Thu, 25 Jan 2007 12:47:08 +0100, Ivo Van Doorn wrote:
> >>> Correct, similar problems have been detected in rt2x00. The temporary
> >>> solution in there is to demand a scanning operation after the
> >>> interface has been brought up.
> >> Scanning? No no no, please! That would be a clear bug and misbehaviour.
> >>
> >> Jiri
> > 
> > Oh?  I'm sitting here watching the tty0 screen of my lappy after x has 
> > been started, and I have established a connection, but SoftMAC is still 
> > logging its scan activity, starting with channel 1 and scanning 14 
> > channels.  Its doing this at approximately 2 minute intervals.  So I 
> > think we have your definition of a clear bug and misbehaviour.
> > 
> 
> Are you running NetworkManager? If so, that is the source of the scanning.

Right; and NM scans at 2m intervals by default, unless you've clicked
the menu (or a few other instances) where it will jump up to 20s and
then back off to 2m again.

dan


> Larry
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

