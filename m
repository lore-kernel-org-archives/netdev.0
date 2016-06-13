From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: udp failures traced to e858fae2b0b8
Date: Mon, 13 Jun 2016 07:48:39 -0600
Message-ID: <2ba80fe2-8274-33e2-afef-70170f31002c@cumulusnetworks.com>
References: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
 <20160613064202.GA14048@rapoport-lnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34039 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423355AbcFMNsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 09:48:50 -0400
Received: by mail-pf0-f169.google.com with SMTP id 62so46533328pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 06:48:49 -0700 (PDT)
In-Reply-To: <20160613064202.GA14048@rapoport-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/16 12:42 AM, Mike Rapoport wrote:
> Hi David,
>
> On Sun, Jun 12, 2016 at 08:47:20PM -0600, David Ahern wrote:
>> Mike:
>>
>> UDP tests in my vrf unit test suite are failing. git bisect points to:
>
> Are you testing host or guest kernel?

Problem is with guest. Guest is running net-next kernel.

host is running 4.6.
