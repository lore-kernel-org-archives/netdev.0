From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip link: Add support for kernel side filtering
Date: Mon, 16 May 2016 12:30:53 -0600
Message-ID: <7f0bf9e9-ecb4-419e-29c9-254e43546e77@cumulusnetworks.com>
References: <1462974718-12860-1-git-send-email-dsa@cumulusnetworks.com>
 <20160516111931.1aaac4f3@xeon-e3>
 <7fb315f5-43c7-bcf1-f317-dab0a352f206@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35906 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbcEPSaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:30:55 -0400
Received: by mail-io0-f172.google.com with SMTP id i75so215381714ioa.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:30:55 -0700 (PDT)
In-Reply-To: <7fb315f5-43c7-bcf1-f317-dab0a352f206@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/16 12:27 PM, David Ahern wrote:
> In general older kernels do not parse the attributes appended to the get
> request.

sorry, wrong wording: the attributes are parsed but ignored. I just 
checked an older 3.4 kernel tree and that is true there as well as prior 
to the kernel commit for this feature.
