From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2 add hoplimit and reordering route options
 usage and parsing
Date: Tue, 6 Oct 2009 13:41:42 +0200
Message-ID: <20091006114142.GA11012@amd64.fatal.se>
References: <1254732861.015524.19779.nullmailer@watson.codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:54027 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbZJFLlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 07:41:45 -0400
Received: from iph1.telenor.se (195.54.127.132) by proxy3.bredband.net (7.3.140.3)
        id 49F597CD040484A8 for netdev@vger.kernel.org; Tue, 6 Oct 2009 13:41:05 +0200
Content-Disposition: inline
In-Reply-To: <1254732861.015524.19779.nullmailer@watson.codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Mon, Oct 05, 2009 at 10:54:21AM +0200, Gilad Ben-Yossef wrote:
> iproute2 git HEAD (spotted originally on 2.6.26, so it's probably not new) 
> does  not parse the hoplimit route option when proccessing parameters, nor 
> does it  print hoplimit and reordering options in the usage lines.  

I'm happy you brought this up and know the author. The Debian package
has been carrying this code, which is now in the form of a patch available
here:
http://git.debian.org/?p=collab-maint/pkg-iproute.git;a=blob;f=debian/patches/hoplimit.dpatch

I didn't know who the original author was which is why I haven't submitted it,
but it seems you know the history....
The above patch also includes some minor documentation updates which you seem
to be missing and might want to integrate in your version of the patch.

Looking forward to be able to drop the patch in the debian package!

Regards,
Andreas Henriksson
