From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/3 net-next] Bring sizeof(net_device) down to < 2K bytes
Date: Thu, 9 Apr 2015 17:01:52 -0700
Message-ID: <20150410000151.GA1728@Alexeis-MBP.westell.com>
References: <cover.1428622095.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37694 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbbDJAB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 20:01:56 -0400
Received: by igblo3 with SMTP id lo3so5424411igb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 17:01:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 01:43:25AM +0200, Thomas Graf wrote:
> The size of struct net_device crossed the 2K boundary a while ago which
> is a waste in combination with many net namespaces. This series brings
> the size of struct net_device down to well below 2K in total size with
> a typical configuration. Some reserves a several holes leave room for
> further expansion.

Great stuff!
Can you share what was the sizeof(struct net_device) with typical
x86 config before and after?
