From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sctp: Add process name and pid to deprecation warnings
Date: Fri, 3 Jan 2014 00:18:37 +0000
Message-ID: <1388708317.22017.25.camel@deadeye.wl.decadent.org.uk>
References: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
	 <1388692350.9947.37.camel@bwh-desktop.uk.level5networks.com>
	 <20140102203036.GC7526@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46297 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbaACASk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:18:40 -0500
In-Reply-To: <20140102203036.GC7526@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 15:30 -0500, Neil Horman wrote:
> On Thu, Jan 02, 2014 at 07:52:30PM +0000, Ben Hutchings wrote:
> > On Thu, 2014-01-02 at 12:54 -0500, Neil Horman wrote:
> > > Recently I updated the sctp socket option deprecation warnings to be both a bit
> > > more clear and ratelimited to prevent user processes from spamming the log file.
> > > Ben Hutchings suggested that I add the process name and pid to these warnings so
> > > that users can tell who is responsible for using the deprecated apis.  This
> > > patch accomplishes that.
> > [...]
> > 
> > I grepped for existing deprecation warnings that log the command and/or
> > PID.  The warnings are not consistent, but where the include both comand
> > and PID it's generally in the format "%s (%d)", comm, pid.  So please
> > could you follow that format?
> > 
> Thats not really true, Subsystems vary widely in how they present process
> name/pid warnings.  In fact, the first example you give below that uses both
> process and pid, the format is <pid> (<name>)
> 
> There are alot that use <name> (<pid>), I argee, but theres quite alot of others
> as well (the lockdep subssytem uses %s/%d, and several of the arm trap handlers
> actually use Process <name> (pid: <pid>).

Ah, I was just looking specifically at deprecation warnings.  I can see
that broader consistency is also worthwhile.

> I don't have any issue with changing
> it, but I'm not sure what the advantage is if theres not going to be consistent
> use throughout the kernel.

Well I thought you were trying to improve that, starting with that
DEPRECATED macro.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
