From: jamal <hadi@cyberus.ca>
Subject: Re: processes / net connections - an API
Date: Fri, 11 May 2007 08:47:49 -0400
Message-ID: <1178887669.4093.35.camel@localhost>
References: <f21o3o$ri1$1@sea.gmane.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stf <stf_polska@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.243]:54508 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbXEKMrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 08:47:52 -0400
Received: by ag-out-0708.google.com with SMTP id 23so992780agd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 05:47:52 -0700 (PDT)
In-Reply-To: <f21o3o$ri1$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 14:41 +0200, stf wrote:
> Hi!
> 
> I want to write a library or application showing processes and net 
> connections. I was looking on ps and netstat to see how those programs 
> are retrieving the information. It seems that they are parsing /proc 
> entries.
> 
> Is there any other kernel API to get information about processes or net 
> connections?
> 

For processes, take a look at kernel-sources/accounting/*
For networking, your question is hard to answer because netstat really
wont tell you much about flows; in any case, but take a look at
iproute2-sources/iproute2/misc/*

cheers,
jamal


