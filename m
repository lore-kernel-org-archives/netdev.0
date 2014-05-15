From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/3] iproute2: arpd: use ll_addr_a2n and
 ll_addr_n2a
Date: Thu, 15 May 2014 18:50:51 +0200
Message-ID: <20140515165051.GA2939@minipsycho.orion>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
 <1400159422-11797-2-git-send-email-jiri@resnulli.us>
 <20140515084342.1aaae42a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:54011 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbaEOQuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 12:50:55 -0400
Received: by mail-ee0-f43.google.com with SMTP id d17so836494eek.16
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 09:50:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140515084342.1aaae42a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 15, 2014 at 05:43:42PM CEST, stephen@networkplumber.org wrote:
>On Thu, 15 May 2014 15:10:20 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  misc/arpd.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>> 
>
>Why not use more standard ether_ntoa ?

Because the rest of the code uses ll_addr_n2a. There is no user of
ether_ntoa in iproute2.
