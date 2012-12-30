From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Sat, 29 Dec 2012 23:44:03 -0200
Message-ID: <20121230014403.GA2077@obelix.rh>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
 <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab2L3BoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 20:44:07 -0500
Content-Disposition: inline
In-Reply-To: <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 05:29:45PM -0800, Stephen Hemminger wrote:
> On Sat, 29 Dec 2012 23:19:26 -0200
> Flavio Leitner <fbl@redhat.com> wrote:
> 
> > This patch adds few ethtool operations to team driver.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> What is the motivation for this? Is there an application that depends
> on ethtool (versus netlink, or /proc)?

Speaking as a support engineer, it's a lot easier to grab ethtool -S and
see everything than grab two or more outputs.

> Sorry, I see no point in providing ethtool statistics for generic data that is already
> reported by existing netlink and other infrastructure. The purpose of ethtool
> statistics is to report device specific that is not available through the normal
> generic statistics.

Right, but those statistics can be device specific as well.  The tg3 and bnx2, for
instance, do the same reporting [rx|tx]_bytes|octets. 

I see no harm, and it is helpful. 

-- 
fbl
