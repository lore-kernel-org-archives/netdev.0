From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Fri, 25 Dec 2009 15:22:00 -0800
Message-ID: <20091225152200.1cf11dfe@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B34E847.8010809@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757383AbZLYXXK@vger.kernel.org>
In-Reply-To: <4B34E847.8010809@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Dec 2009 11:28:55 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

>   More data points - I'm able to reliably recreate this now.
> While I thought it was coincidence, each and every time I hit this issue 
> there is a DHCP renew event immediately before the first error.
> The crash occurs while under load - in my case seems that the traffic is 
> actually IPV6 (hadn't noticed that before).
> I ran nethogs on a remote display - the reported rx rate on the IPV6 smb 
> connection at the time of the lockup was 33889.688 KB/sec on a 1gbit 
> nic. I've got two events like this - don't recall if the earlier one was 
> the exact same # - but it was in the ballpark.
> 
> On 12/24/2009 2:01 AM, Andrew Morton wrote:
> > cc's added again.
> >
> > On Wed, 23 Dec 2009 17:54:27 -0500 Michael Breuer<mbreuer@majjas.com>  wrote:
> >
> >    
> >> Ok - not the firmware.  Ran another Windows backup and sky2 went down.
> >>
> >> Nothing in dmesg.old - have oops in syslog. System became unresponsive
> >> and watchdog kicked in after a minute.
> >>
> >> Also note that I have a similar oops with VT-D disabled (posted here on
> >> 12/5). I'm attaching the oops from that below this oops for comparison.
> >> That also happened under similar load.
> >>
> >> On the assumption that I can recreate this (although it takes a while)
> >> please let me know how I can help.
> >>
> >> What's in my log (starting with an smbd error about 2 min before the
> >> oops (note: the dchpd is not the system doing the backup).
> >>      
> > This (nastily wordwrapped) oops appers to be quite different from
> > Berck's one.
> >
> >

What is the MTU?
> 


-- 
