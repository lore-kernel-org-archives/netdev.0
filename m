From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: r8169 not working under latest kernels
Date: Fri, 17 May 2013 11:15:02 +0300
Message-ID: <106b9e6e996f2801b46b09c5bc5f168d@visp.net.lb>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
 <678d818cc06d1da382dc14397ad41c7e@visp.net.lb>
 <20130516225735.GB20140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45497 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3EQIPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:15:05 -0400
In-Reply-To: <20130516225735.GB20140@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-05-17 01:57, Francois Romieu wrote:
> Denys Fedoryshchenko <denys@visp.net.lb> :
> On 2013-05-13 14:59, Denys Fedoryshchenko wrote:
> [...]
> >Noticed on 32-builds of my systems that r8169 is not working
> >anymore at all.
> >Problem started to occur somewhere after 3.6 kernels, but it is
> >difficult to try other kernels on this semi-embedded system, and i am
> >not completely sure about that.
> >Once i used another OS build, but 64-bit build with same latest
> >kernel, and it worked.
> [...]
> It is not only for that model, i faced this problem for many realtek
> cards. Probably as i mentioned something specific (such as ifplugd
> interface polling) causing that, but it is making almost all r8169
> cards unusable for me.
> 
> 32-bit built KO vs 64-bit built OK does not ring a bell. I must go to
> bed now but your .config and 32-bit r8169.ko will be welcome.
> 
> Thanks.
http://www.nuclearcat.com/files/config-r8169.txt
I will try to use this config with 64bit kernel on same system (with 
32bit same userspace), to be sure if there is any difference.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
