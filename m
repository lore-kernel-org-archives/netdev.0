From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP
 packets as mpls
Date: Tue, 2 Jun 2015 23:37:38 +0200
Message-ID: <20150602213738.GA5842@pox.localdomain>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
 <1433177175-16775-4-git-send-email-rshearma@brocade.com>
 <87a8wivue4.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33882 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbFBVhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:37:41 -0400
Received: by wibut5 with SMTP id ut5so82644798wib.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 14:37:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87a8wivue4.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/15 at 01:26pm, Eric W. Biederman wrote:
> What we really want here is xfrm-lite.  By lite I mean the tunnel
> selection criteria is simple enough that it fits into the normal
> routing table instead of having to do weird flow based magic that
> is rarely needed.
> 
> I believe what we want are the xfrm stacking of dst entries.

I assume you are referring to reusing the selector and stacked
dst. I considered that for the transmit side.

Can you elaborate on this some more? How would this look like
for the specific case of VXLAN? Any thoughts on the receive
side? You also mention that you dislike the net_device approach.
What do you suggest instead? The encapsulation is often postponed
to after the packet is fully constructed. Where should it get
hooked into?
