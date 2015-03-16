From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Mon, 16 Mar 2015 16:42:09 +0200
Message-ID: <20150316144209.GA1401@angus-think.wlc.globallogic.com>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
 <5505EFC4.1070403@iogearbox.net>
 <20150316132230.GA1100@angus-think.wlc.globallogic.com>
 <5506ECDE.6000302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:36395 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128AbbCPOxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 10:53:55 -0400
Received: by lamx15 with SMTP id x15so42147411lam.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 07:53:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5506ECDE.6000302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 03:46:54PM +0100, Daniel Borkmann wrote:
> On 03/16/2015 02:22 PM, Vadim Kochan wrote:
> ...
> >Also I was thinking about to get rid of this '-nm | -name' option and
> >resolve class names by default if they are in /etc/iproute2/cls_names or
> >specified by -cf option, what do you think ?
> 
> Generally, I think that would be good, but it could break applications
> or shell scripts' expectations if they do parse tc output. I think if
> admins do care, they could simply set up an alias.
> 
> Cheers,
> Daniel

Hm, yes, so may be let this option exist, but then may be it
should not fail if the default file /etc/iproute2/cls_names does not
exist.

Regards,
