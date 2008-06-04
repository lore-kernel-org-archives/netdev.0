From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Thu, 05 Jun 2008 00:00:08 +0300
Message-ID: <48470258.8050701@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com>	<4846B5F2.8090805@gmail.com>	<396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com> <20080604092154.7511c9d3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:50846 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbYFDVAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 17:00:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so152741fgg.17
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 14:00:11 -0700 (PDT)
In-Reply-To: <20080604092154.7511c9d3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> TCP should recover from this anyway. As soon as any activity happens
> on the connection the other end will respond with reset.  For an IMAP
> session doing the next get-mail should cause a connection reset.
> Now it is possible that mail client has other problems.
> 

I will check this again, but this isn't specific to imap,
I remember that leaving a running download results is same hang behavior.
(I agree that after a bit long timeout (about 1~2 minutes) connection is 
reset, but this is annoying, especially if you turned up your system to 
read mail.)

And exiting kmail won't help, since it does mail i/o via kio ioslave
and thus I have to ether wait 2 minutes or kill this ioslave.

Best regards,
	Maxim Levitsky
