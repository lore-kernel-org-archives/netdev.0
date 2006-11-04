From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [Info]d80211 : Understanding d80211
Date: Fri, 03 Nov 2006 22:15:59 -0600
Message-ID: <454C13FF.6070902@lwfinger.net>
References: <d9a09df00611031943n41cf27beu566383b0e1c96197@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:10449 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1752742AbWKDEQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 23:16:35 -0500
To: Udayan Singh <udayan.singh@gmail.com>
In-Reply-To: <d9a09df00611031943n41cf27beu566383b0e1c96197@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Udayan Singh wrote:
> Hi,
> 
> I wanted to understand the code of d80211 (thanks to James Ketrenos
> for the info he provided) and also work in it.
> 
> I found that I can get the latest patches regarding the same from :
> 
> http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

Wireless-2.6 contains the developmental version of wireless code _NOT_ using d80211. The d80211 
development version is at git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git 
and must be downloaded with git, not ftp or http.
> 
> Also, in the main kernel tree the development for 802.11 is in
> "drivers/net/wireless/*" .

The d80211 drivers are in drivers/net/wireless/d80211/*. The drivers in drivers/net/wireless/* do 
not use d80211.

> 
> Well, I did not find any reference of d80211 in lk 2.6.18.1, though a
> few places I read that the possible merger would be in lk 2.6.19. I
> hope I got it right ?

The merger of d80211 with mainline kernel will occur with 2.6.21 or later. At the moment, there are 
several reasons for it not to be included in the mainline kernel. The stable kernels (2.6.18.X and 
earlier), and the mainline developmental kernel (2.6.19-rcX) do not include the d80211 code.

> Any docs that I can read through that you would recommend from where I
> can start up ?

Only the code AFAIK.

> Is there any place where I can download the code in a similar pattern
> as we do from kernel.org for the mainstream kernel ?

See the previous git reference.

Larry

