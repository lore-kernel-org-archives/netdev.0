From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v6 0/3] net: reserve ports for applications using fixed port numbers
Date: Wed, 10 Mar 2010 14:42:47 +0200
Message-ID: <201003101442.47192.opurdila@ixiacom.com>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com> <m1vddbdhmo.fsf@fess.ebiederm.org> <4B976503.4050702@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B976503.4050702@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 March 2010 11:23:15 you wrote:
> Eric W. Biederman wrote:
> > I would add the restriction that the values in the list of ranges
> > always must be increasing, and in general restrict the set of accepted
> > values as much as possible.  If we don't accept it now we don't have
> > to worry about some userspace application relying on some unitended
> > side effect a few years into the future.
> 
> I don't think this is good.
> 
> Suppose that when I just want to add one port into the list and keep the
> original ones, I want to do this:
> 
> orig=$(cat ip_local_reserved_ports)
> new_list="$orig, $new_one"
> echo "$new_list" > ip_local_reserved_ports
> 
> If we add this restriction, the above could be failed if the new port
> is lower than the original ones. This will be not convenient.
> 
> > I think it is a serious bug that you clear the destination bitmap
> > in the middle of parsing it.  That will either open or close all
> > ports in the middle of parsing, and I can't see how that would
> > ever be a good thing.
> 
> Agreed.
> 
> By the way, Octavian, any new updates?
> 

Sorry, didn't got time to work on this lately, but I will submit a new version 
I hope end of this week to address Eric's comments.
