From: "Karl Meyer" <adhocrocker@gmail.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Thu, 16 Aug 2007 23:03:35 +0200
Message-ID: <be1b757c0708161403r3faa7190wd74ac1ecc8aa8f45@mail.gmail.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
	 <20070813165821.GA19356@electric-eye.fr.zoreil.com>
	 <be1b757c0708131027v5c57822as2d9bd3190fd19b71@mail.gmail.com>
	 <20070814070901.GA14693@electric-eye.fr.zoreil.com>
	 <be1b757c0708141425qd887581n3922702b84a21758@mail.gmail.com>
	 <20070814224629.GB3495@electric-eye.fr.zoreil.com>
	 <20070816141122.GA6625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:62384 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbXHPVDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 17:03:37 -0400
Received: by fk-out-0910.google.com with SMTP id z23so295765fkz
        for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 14:03:36 -0700 (PDT)
In-Reply-To: <20070816141122.GA6625@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did some testing today and found that the error occurs after
applying some of the patches. However I did not figure out the exact
patch in which the error "starts" since it sometimes occurs immediatly
when moving some data over the net and sometimes it takes 30 min till
I get the transmit timeout. I will be away till sunday and do some
more testing then.

2007/8/16, Francois Romieu <romieu@fr.zoreil.com>:
> (please do not remove the netdev Cc:)
>
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > If it does not work I'll dissect 0e4851502f846b13b29b7f88f1250c980d57e944
> > tomorrow.
>
> You will find a tgz archive in attachment which contains a serie of patches
> (0001-... to 0005-...) to walk from 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2
> to 0e4851502f846b13b29b7f88f1250c980d57e944 in smaller steps.
>
> Please apply 0001 on top of 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2. If it
> still works, apply 0002 on top of 0001, etc.
>
> --
> Ueimor
>
>
