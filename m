From: roopa <roopa@cumulusnetworks.com>
Subject: Re: parsing the output of ethtool programmatically
Date: Mon, 07 Sep 2015 19:52:54 -0700
Message-ID: <55EE4D86.5080902@cumulusnetworks.com>
References: <558B5937.4080600@unix-beratung.de> <1441446794.13323.8.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Urban <urban@unix-beratung.de>, bwh@kernel.org,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36695 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbIHCw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 22:52:56 -0400
Received: by padhk3 with SMTP id hk3so25502537pad.3
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 19:52:55 -0700 (PDT)
In-Reply-To: <1441446794.13323.8.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/15, 2:53 AM, Ben Hutchings wrote:
> On Thu, 2015-06-25 at 03:28 +0200, Robert Urban wrote:
>> Hello,
>>
>> there doesn't seem to be any flag to request ethtool to present its output in a
>> script-friendly form.  Things like:
>>>          Link partner advertised link modes:  10baseT/Half 10baseT/Full
>>>                                               100baseT/Half 100baseT/Full
>>>                                               1000baseT/Full
>> are kind of pain to parse.
>>
>> Something to consider?
> Or write a library for using SIOCETHTOOL.  The interface is fairly well
> documented now and there are other users besides the ethtool utility.

one of the requests which we usually get is ethtool output in json 
format. since iproute2 tools are already getting
an option to print in json format, would be nice if we considered an 
option to print in json for ethtool too.
