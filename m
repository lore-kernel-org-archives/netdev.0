From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP Congestion Control Algorithms
Date: Mon, 31 Aug 2009 15:07:31 -0700
Message-ID: <20090831150731.28c36081@nehalam>
References: <a45e9b40908311408l15d68088i459d6a1000cbca07@mail.gmail.com>
	<a45e9b40908311410m486a60fel6a81c334732de358@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lisong Xu <lisongxu2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49148 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbZHaWHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 18:07:34 -0400
In-Reply-To: <a45e9b40908311410m486a60fel6a81c334732de358@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Aug 2009 16:10:59 -0500
Lisong Xu <lisongxu2@gmail.com> wrote:

> Hello,
> 
> Since there are multiple different TCP congestion control algorithms
> available in Linux, a Linux server may use any of them.
> 
> Is it possible for a regular user to find out the exact TCP congestion
> control algorithm used by a Linux server? For example, if I am
> downloading a file from a remote Linux server using a TCP flow, can I
> find out whether this flow is a TCP/CUBIC flow, or TCP/Newreno, or
> some other TCP protocol?
> 

No. you might be able to some nmap style guessing, but no remote
API. You can see locally on the server through /proc/sys/net
