From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000 poor network performance - 2.6.17-rc5-g705af309
Date: Sat, 27 May 2006 14:10:17 -0700
Message-ID: <4807377b0605271410j39532f44j2cafd3239d40bf31@mail.gmail.com>
References: <20060526212243.GA19250@SDF.LONESTAR.ORG>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org,
	"NetDEV list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:14006 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964976AbWE0VKT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 17:10:19 -0400
Received: by nf-out-0910.google.com with SMTP id k26so10795nfc
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 14:10:18 -0700 (PDT)
To: "Aravind Gottipati" <aravind@freeshell.org>
In-Reply-To: <20060526212243.GA19250@SDF.LONESTAR.ORG>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/26/06, Aravind Gottipati <aravind@freeshell.org> wrote:
> Hi,
>
> I recently started running linux on a new x60 thinkpad and started
> noticing really poor network performance with this kernel.  I saw some
> archived threads from a while back saying this could be related to
> conntracking.  Disabled that (rmmod ip_conntrack) did not fix the
> problem.  I also tried disabling tso but that didn't have any effect
> either.  I can reproduce the problem when connected to a 100Mbps switch
> (I don't have a GigE network to test this with).

First, lets move this over to netdev (see CC)

> This laptop uses the Intel 82573L (PCI-Express) chip.  I'd be glad to
> assist with any toubleshooting/testing w.r.t this.  I am not subscribed
> to the list, so please cc me on any replies.

What kind of poor performance?  what test? please send the output of
ethtool -e ethX and ethtool -S ethX after you've been having problems.

please provide more details and we can see if we can help.

Jesse
