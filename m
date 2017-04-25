From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC 0/4] xdp: use netlink extended ACK reporting
Date: Tue, 25 Apr 2017 14:00:04 -0700
Message-ID: <20170425140004.16d92683@cakuba.netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
        <58FF1157.8030309@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:51852 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S945772AbdDYVA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 17:00:27 -0400
In-Reply-To: <58FF1157.8030309@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Apr 2017 11:05:27 +0200, Daniel Borkmann wrote:
> > adding #defines for the most common configuration conflicts?
> > Sharing the messages verbatim between drivers could make them easier
> > to google.  
> 
> Makes sense, once more drivers adapt to this reporting, these
> messages could be consolidated.

There seem to be concerns about standardizing/turning the strings into
ABI.  I will leave it out for now, but we can revisit later :)
