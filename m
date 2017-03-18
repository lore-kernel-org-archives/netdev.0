From: Daniele Orlandi <daniele@orlandi.com>
Subject: Re: SO_BINDTODEVICE in VRFs not working?
Date: Sat, 18 Mar 2017 13:02:45 +0100
Message-ID: <ba46da79-be30-b69c-583b-14673e468a6c@orlandi.com>
References: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com>
 <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from submission.geniusware.it ([62.212.12.144]:41199 "EHLO
        submission.orlandi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751320AbdCRM2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 08:28:04 -0400
In-Reply-To: <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/2017 06:54, David Ahern wrote:
>
>>   int s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
>>
>>   char *ifname = "eth1";
> 
> Bind to the VRF device not an interface enslaved to it.

Oh... thanks, it was that simple...

Well, yes, I think it should be possible to bind to the specific
interfaces too although it's not what I was looking for.

Thank you,
Bye,

-- 
  Daniele Orlandi
