From: Auke Kok <sofar@foo-projects.org>
Subject: Re: E1000 stopped transmitting in rc3.
Date: Thu, 27 Apr 2006 18:54:28 -0700
Message-ID: <445175D4.8010209@foo-projects.org>
References: <20060428001352.GA3319@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:3516 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965170AbWD1Byd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 21:54:33 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060428001352.GA3319@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> With 2.6.17-rc3, my E1000 won't get a dhcp lease.
> Looking at tcpdump and ifconfig output, it's easy to see why.
> It's recieving packets, but the packets transmitted field
> of ifconfig never increases.
> 
> The last version I have built that worked ok was 2.6.17rc2-git3

*puzzled*

the only patch between 2.6.17rc2 and 2.6.17rc3 contains an rx-path patch, but 
nothing that affects tx. All the other patches sent earlier are queued for 
2.6.18 so they don't apply.

Auke
