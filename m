From: Robert Urban <urban@unix-beratung.de>
Subject: Re: parsing the output of ethtool programmatically
Date: Thu, 26 Oct 2017 02:21:57 +0200
Message-ID: <8f53f1ee-ddc6-d7c2-075a-02cf4a529d70@unix-beratung.de>
References: <558B5937.4080600@unix-beratung.de>
 <1441446794.13323.8.camel@decadent.org.uk>
 <55EE4D86.5080902@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: bwh@kernel.org, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>,
        Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dna.y42.org ([138.201.40.98]:47269 "EHLO dna.y42.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932124AbdJZAaz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 20:30:55 -0400
In-Reply-To: <55EE4D86.5080902@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

may I also suggest being able to specify the offload parameters in the format in
which "ethtool -k <nic>" prints them? The user can only guess which -K
parameters correspond to the -k parameters.


On 09/08/2015 04:52 AM, roopa wrote:
> On 9/5/15, 2:53 AM, Ben Hutchings wrote:
>> On Thu, 2015-06-25 at 03:28 +0200, Robert Urban wrote:
>>> Hello,
>>>
>>> there doesn't seem to be any flag to request ethtool to present its output in a
>>> script-friendly form.  Things like:
>>>>          Link partner advertised link modes:  10baseT/Half 10baseT/Full
>>>>                                               100baseT/Half 100baseT/Full
>>>>                                               1000baseT/Full
>>> are kind of pain to parse.
>>>
>>> Something to consider?
>> Or write a library for using SIOCETHTOOL.  The interface is fairly well
>> documented now and there are other users besides the ethtool utility.
>
> one of the requests which we usually get is ethtool output in json format.
> since iproute2 tools are already getting
> an option to print in json format, would be nice if we considered an option to
> print in json for ethtool too.
>
>
