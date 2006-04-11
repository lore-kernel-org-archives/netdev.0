From: Daniel Drake <dsd@gentoo.org>
Subject: Re: 2.6.17 regression: Very slow net transfer from some hosts
Date: Tue, 11 Apr 2006 23:20:42 +0100
Message-ID: <443C2BBA.5010804@gentoo.org>
References: <443C03E6.7080202@gentoo.org> <443C024C.2070107@psc.edu> <443C0B74.50305@gentoo.org> <443C09A7.2040900@psc.edu> <443C1738.20605@gentoo.org> <443C178B.3030805@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751146AbWDKWII@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <443C178B.3030805@psc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> This is almost certainly due to a buggy firewall that doesn't understand 
> TCP window scaling.  I've usually seen this in the past with OpenBSD 
> firewalls.  Do you have one of these in your path?

At home I'm behind a Linux gateway box currently running 2.6.15-rc6 - I 
am connected through ethernet to that.

At my student house I am connected wirelessly to a Linksys WRT54Gv5 
router (the model that doesnt run Linux).

I have reproduced it at both those locations (same ISP).

This is very familiar, and I just found the article I was thinking of: 
http://lwn.net/Articles/92727/

I was also hit by that bug, on the same collection of websites, but that 
particular problem was fixed for 2.6.8 or so. So I guess it is extremely 
likely that my ISP has broken routers. nmap isn't able to identify the 
OS of any ISP routers in my path.

It's a huge ISP over here, so contacting them over technical matters is 
not easy...

Thanks,
Daniel
