From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 13:05:12 -0800
Message-ID: <20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
References: <424C6089.1080507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C6089.1080507@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You need to cleanup the style.  
	Lots of dead commented out code.
	Encapsulating locking in macros is ugly and makes maintenance a nuisance.
       CamelCaps
        Use prdebug instead of DEBUG
	RCU instead of rwlock's or just use spinlock
	Adding new /proc interfaces is frowned on
	Adding new ioctl's are very frowned on
	global namespace issues with toupper et a..
