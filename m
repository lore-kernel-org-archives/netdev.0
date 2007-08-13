From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Mon, 13 Aug 2007 18:58:21 +0200
Message-ID: <20070813165821.GA19356@electric-eye.fr.zoreil.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Karl Meyer <adhocrocker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56906 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030788AbXHMRAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 13:00:52 -0400
Content-Disposition: inline
In-Reply-To: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(netdev Cced)

Karl Meyer <adhocrocker@gmail.com> :
[...]
> I am having trouble with the 2.6.23 kernel. With all versions since
> 2.6.23-rc1 I have trouble with my network connection. When using the
> network over a certain level (just browsing the web seems not to be
> enough) e.g. when installing packages over the nvsv4 share, all
> network stuff freezes for some time and syslog tells me:
> Aug 13 13:16:09 frege NETDEV WATCHDOG: eth0: transmit timed out
> Aug 13 13:16:39 frege NETDEV WATCHDOG: eth0: transmit timed out
> Aug 13 13:17:09 frege NETDEV WATCHDOG: eth0: transmit timed out
> Aug 13 13:17:57 frege NETDEV WATCHDOG: eth0: transmit timed out

Can you:
- send a complete dmesg + /proc/interrupts + .config
- use git bisect to find a suspect changeset
  I do not expect any change of behavior between 2.6.22 and
  25805dcf9d83098cf5492117ad2669cd14cc9b24 if it can help you narrow
  things down (assuming it is a r8169 regression).

-- 
Ueimor
