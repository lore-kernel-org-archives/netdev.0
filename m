From: John Nielsen <lists@jnielsen.net>
Subject: Re: [PATCH net] vxlan: re-ignore EADDRINUSE from igmp_join
Date: Tue, 1 Sep 2015 15:02:23 -0600
Message-ID: <173BB23A-4D43-4B41-9082-4E1F5CC81B8A@jnielsen.net>
References: <55DCB958.3080904@gmail.com> <78f32de72ff150f6a1260f44a409cfed915a17e1.1440544648.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail2.jnielsen.net ([50.114.224.20]:36145 "EHLO
	webmail2.jnielsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611AbbIAVCa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 17:02:30 -0400
In-Reply-To: <78f32de72ff150f6a1260f44a409cfed915a17e1.1440544648.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 25, 2015, at 5:22 PM, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com> wrote:

> Before 56ef9c909b40[1] it used to ignore all errors from igmp_join().
> That commit enhanced that and made it error out whatever error happened
> with igmp_join(), but that's not good because when using multicast
> groups vxlan will try to join it multiple times if the socket is reused
> and then the 2nd and further attempts will fail with EADDRINUSE.
> 
> As we don't track to which groups the socket is already subscribed, it's
> okay to just ignore that error.
> 
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Reported-by: John Nielsen <lists@jnielsen.net>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> 
> John, please see how this goes for you. It worked in here.

Confirmed working here. Thanks again!
