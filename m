From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH] fix kernel crash in the macvlan driver
Date: Thu, 7 Jun 2012 14:32:46 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1206071432021.87881@animac.local>
References: <alpine.OSX.2.00.1206071137360.86561@animac.local> <87bokux5po.fsf@xmission.com> <alpine.OSX.2.00.1206071320040.86561@animac.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40586 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab2FGVcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 17:32:50 -0400
Received: by dady13 with SMTP id y13so1428720dad.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 14:32:49 -0700 (PDT)
In-Reply-To: <alpine.OSX.2.00.1206071320040.86561@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Now since, macvlan_common_newlink() symbol has been exported but dellink() is not, it

oops, sorry. Not sure what I was looking at. dellink() has also been
exported and is used by macvtap.c. So no issues here.

ani
