From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/21] netfilter updates for net-next
Date: Sun, 27 Jan 2013 00:56:45 -0500 (EST)
Message-ID: <20130127.005645.1941744802495301026.davem@davemloft.net>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 25 Jan 2013 14:54:32 +0100

> * The new connlabel extension for x_tables, that allows us to attach
>   labels to each conntrack flow. The kernel implementation uses a
>   bitmask and there's a file in user-space that maps the bits with the
>   corresponding string for each existing label. By now, you can attach
>   up to 128 overlapping labels. From Florian Westphal.
> 
> * A new round of improvements for the netns support for conntrack.
>   Gao feng has moved many of the initialization code of each module
>   of the netns init path. He also made several code refactoring, that
>   code looks cleaner to me now.
> 
> * Added documentation for all possible tweaks for nf_conntrack via
>   sysctl, from Jiri Pirko.
> 
> * Cisco 7941/7945 IP phone support for our SIP conntrack helper,
>   from Kevin Cernekee.
> 
> * Missing header file in the snmp helper, from Stephen Hemminger.
> 
> * Finally, a couple of fixes to resolve minor issues with these
>   changes, from myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks Pablo.
