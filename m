From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.17 regression: Very slow net transfer from some hosts
Date: Tue, 11 Apr 2006 20:42:24 -0400
Message-ID: <443C4CF0.8040508@psc.edu>
References: <443C03E6.7080202@gentoo.org>	<443C024C.2070107@psc.edu>	<443C0B74.50305@gentoo.org>	<443C09A7.2040900@psc.edu>	<443C1738.20605@gentoo.org>	<443C178B.3030805@psc.edu>	<443C2BBA.5010804@gentoo.org> <20060411153315.4132b477@localhost.localdomain> <443C4471.7040407@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751216AbWDLAmd@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <443C4471.7040407@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Stephen Hemminger wrote:
>>> This is very familiar, and I just found the article I was thinking 
>>> of: http://lwn.net/Articles/92727/
>>>
>>> I was also hit by that bug, on the same collection of websites, but 
>>> that particular problem was fixed for 2.6.8 or so. So I guess it is 
>>> extremely likely that my ISP has broken routers. nmap isn't able to 
>>> identify the OS of any ISP routers in my path.
>>
>> We never fixed it, its kind of hard to fix other peoples equipment ;-)
> 
> Weird, things started working for me around 2.6.9 without having to 
> modify any sysctl stuff.

Ah, I remember now.  2.6.7 introduced the tcp_default_win_scale 
variable, and 2.6.9 got rid of it, doing the calculation based on the 
max possible tcp rcvbuf.  This is conceptually the right thing to do, 
regardless of broken middleboxes, but had the side effect of hiding this 
latent problem a bit longer.

Thanks,
   -John
