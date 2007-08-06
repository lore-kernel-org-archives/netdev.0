From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: ipsec not working in 2.6.23-rc1-git10 when using pfkey
Date: Mon, 6 Aug 2007 09:45:58 +0300
Message-ID: <200708060945.58797.joakim.koskela@hiit.fi>
References: <200708021858.l72IwbhE018683@faith.austin.ibm.com> <20070802.150114.66056548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:46711 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758311AbXHFGqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 02:46:30 -0400
In-Reply-To: <20070802.150114.66056548.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 August 2007 01:01:14 David Miller wrote:
> Joakim, TEST YOUR PATCHES, and not just with your BEET test cases,
> before submitting them in the future.  Having normal configurations of
> both PF_KEY and XFRM_USER ipsec totally break as a result of your
> changes is totally unacceptable and I will doubly scrutinize your
> patch submissions in the future because of what has happened here.

Ok, seems fair and sorry for all the extra work this caused. Had a creeping 
feeling it would break something (as it so obviously could), but wrote it off 
as paranoia as it didn't seem to negatively affect either transport or tunnel 
mode (..but then again, I was only using the ip tool to manually set them 
up).

br, j
