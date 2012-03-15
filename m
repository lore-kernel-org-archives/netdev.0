From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Methods to communicate between kernel network stack and user
 space
Date: Thu, 15 Mar 2012 09:26:58 -0700
Message-ID: <20120315092658.55f21a3d@nehalam.linuxnetplumber.net>
References: <CAAZheX=0v2AK0aDN0ZE=6n13JF27Nd-jOyi7GPzSSc4cYpnkeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53181 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031664Ab2COQ1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 12:27:00 -0400
In-Reply-To: <CAAZheX=0v2AK0aDN0ZE=6n13JF27Nd-jOyi7GPzSSc4cYpnkeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Look at existing RSTP daemon, it uses bridge netlink and there is no
reason to think TRILL needs anything special.

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git
