From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 0/3] NSH and VxLAN-GPE
Date: Tue, 1 Mar 2016 10:12:34 -0800
Message-ID: <20160301181231.GA95346@ast-mbp.thefacebook.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33730 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbcCASMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:12:40 -0500
Received: by mail-pf0-f169.google.com with SMTP id 124so55445638pfg.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 10:12:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 11:11:46AM +0000, Brian Russell wrote:
> These patches add a new module to support encap/decap of Network
> Service Header (NSH) as defined in:
> 
> https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
> 
> Both NSH Type 1 and Type 2 metadata are supported with a simple registration
> hook to allow listeners to register to see packets with Type 1 or a specific
> class of Type 2 metadata. NSH could be added to packets sent over a variety
> of link types, eg. VxLAN, GRE, ethernet.
> 
> v2 - fix copyright notices and tidy up use of types
> 
> v3 - fix various style issues in nsh module
>      remove VxLAN-GPE changes
>      add nsh logging module as example
>      add nsh netfilter encap target as example

two fake examples are trying to justify EXPORT_SYMBOL(nsh_register_listener) ?!
what's the real meaning of this patch set?
As far as I can see in-tree users cannot do anything useful with it.
