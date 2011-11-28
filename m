From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP fast retransmit
Date: Mon, 28 Nov 2011 13:17:40 -0800
Message-ID: <CAK6E8=e9jpK1QY_zO5oSEC6oM+JgCG+bHcauDPdDOUqz7RSumQ@mail.gmail.com>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:51067 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab1K1VSC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:18:02 -0500
Received: by qyk4 with SMTP id 4so1248142qyk.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 13:18:01 -0800 (PST)
In-Reply-To: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ansgar,

On Fri, Nov 25, 2011 at 5:33 AM, Esztermann, Ansgar
<Ansgar.Esztermann@mpi-bpc.mpg.de> wrote:
> [originally posted to lkml]
> Hello list,
>
> is there some documentation available on TCP fast retransmit? There seem to be quite a lot of descriptions -- from informal to scholarly papers -- on the various algorithms available to calculate the proper size of the congestion window, but I have been unable so far to find out *when* a fast retransmit is triggered. RFC 2581 states the third dupACK "should" do it, and this seems to be quoted fairly often. However, I can easily produce connections that fail to perform fast retransmit even after 5 dupACKs. Some people mention Linux uses a different (presumable more sophisticated) algorithm to trigger fast retransmits, but no-one seems to elaborate.
>

This 2003 paper has the core algorithms for Linux loss recovery.
http://www.cs.helsinki.fi/research/iwtcp/papers/linuxtcp.pdf

We've also detailed latest Linux fast retransmit algorithms in the PRR
paper (section 3.2).
http://research.google.com/pubs/pub37486.html

HTH
