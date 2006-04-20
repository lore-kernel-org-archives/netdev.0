From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: SIOCGIWSCAN wireless event behaviour
Date: Thu, 20 Apr 2006 10:26:43 -0700
Message-ID: <20060420172643.GF1321@instant802.com>
References: <4447979F.4050603@gentoo.org> <1145543852.2654.11.camel@localhost.localdomain> <20060420164354.GA32409@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Daniel Drake <dsd@gentoo.org>,
	softmac-dev@sipsolutions.net, netdev@vger.kernel.org,
	hostap@shmoo.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-75.dex002.intermedia.net ([64.78.20.105]:59975 "EHLO
	DHOST002-75.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751177AbWDTR07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 13:26:59 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20060420164354.GA32409@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 09:43:54AM -0700, Jean Tourrilhes wrote:
> 	After we changed to behaviour of ipw, various users reported
> that wpa_supplicant was confused. I particularly trust the report of
> Bill Moss, who has been hacking ipw for a long time :
> 
> http://sourceforge.net/mailarchive/forum.php?thread_id=10091113&forum_id=38938

Hmm.. Can someone please describe what was changed? Just sending
SIOCGIWSCAN events more frequently? I have not seen any problems with
this in my tests (though, mainly with madwifi-ng). Is the broken case
available in one of the kernel trees? 2.6.16? wireless-2.6? (i.e., where
can I get the exact version of ipw2200 driver that is expected to show
incorrect behavior)?

> 	Jouni was notified, but did not really answer to that bug report.
> 	Then, the ipw maintainers commited the following patch to ipw
> that fix or workaround that issue :
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114492056522667&w=2

Hmm.. I don't remember having seen that report from Bill Moss.. How was
I notified? ;-) The patch here seems to be moving ipw_disassociate()
call, so it is not obviously clear from that what the impact on behavior
is. I can try to reproduce this, but I would like to know what version
to test with in order to avoid any possible workarounds from hiding the
issue.

-- 
Jouni Malinen                                            PGP id EFC895FA
