From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: oh crap... (re: %p6)
Date: Wed, 29 Oct 2008 07:55:24 -0700
Message-ID: <1225292124.20276.12.camel@brick>
References: <20081029.015402.234525839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:5857 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbYJ2Ozb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 10:55:31 -0400
Received: by rn-out-0910.google.com with SMTP id k40so18356rnd.17
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 07:55:29 -0700 (PDT)
In-Reply-To: <20081029.015402.234525839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 01:54 -0700, David Miller wrote:
> I think we'll need to revert all of this or find some fix soon.  GCC
> warns about %p with a '#' flag modifier it seems :-(
> 
> net/ipv6/ip6_flowlabel.c: In function 'ip6fl_seq_show':
> net/ipv6/ip6_flowlabel.c:707: warning: '#' flag used with '%p' printf format

The easiest would be to pick a separate modifier for the raw case.  Or
revert the removal of NIP6_SEQFMT, I'll shoot you a patch shortly,
any preference in what modifier should be used?

Harvey

