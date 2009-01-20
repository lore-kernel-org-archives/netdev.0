From: Paul Moore <paul.moore@hp.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 16:51:42 -0500
Message-ID: <200901201651.43119.paul.moore@hp.com>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local> <200901201553.57022.paul.moore@hp.com> <m2ljt53b8q.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Stephan Peijnik <stephan@peijnik.at>,
	"linux-security-module" <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Samir Bellabes <sam@synack.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:29397 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbZATV6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 16:58:09 -0500
In-Reply-To: <m2ljt53b8q.fsf@ssh.synack.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 January 2009 4:42:45 pm Samir Bellabes wrote:
> Paul Moore <paul.moore@hp.com> writes:
> > However, in dealing with the issue of personal firewalls I think
> > the biggest issue will be the user interaction as you described ...
> > how do you explain to a user who clicked the "allow" button that
> > the system rejected their traffic?
>
> maybe because the personnal firewall is the only one which deal with
> the LSM hook related to network (?)

In the particular case I was responding to there were multiple LSMs 
being executed in quasi-parallel fashion so the personal firewall (in 
this case assumed to be a separate LSM) would not be the only LSM 
implementing network access controls.

> >> For starters, the existing LSM interface and the LSM  modules
> >> themselves could be split up so as to provide
> >>
> >>  selinux.ko
> >>   \_ selinux_net.ko
> >>   \_ selinux_fs.ko
> >>   ...
> >>
> >> just a suggestion to ease the thinking process for now.
> >> If a purely network-related LSM does not have to think about
> >> "do I need to implement FS hooks that do chaining or not..."
> >> it is a lot better off.
> >
> > Unfortunately I don't think this solves the problem, it just
> > changes it slightly.  It is no longer "How do I enable SELinux and
> > XXX personal firewall?" but instead "How do I enable SELinux's
> > network access controls and XXX personal firewall?"
>
> And introduce another one : "how do I make SElinux's network access
> controls and Apparmor filesystem access controls working together ?"
> this is the true deal in this kind of solution.

That is also an issue.  Needless to say I doubt the "choose your own 
adventure" approach to security is a good idea.

-- 
paul moore
linux @ hp
