From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Mon, 09 Feb 2015 07:54:50 -0800
Message-ID: <54D8D84A.2080203@cumulusnetworks.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <54D3F8F9.2060500@cumulusnetworks.com> <20150206081046.415c3d50@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
	ebiederm@xmission.com, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org, Eyal Birger <eyal.birger@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53720 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933209AbbBIPyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:54:52 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so34670870pab.5
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 07:54:51 -0800 (PST)
In-Reply-To: <20150206081046.415c3d50@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15, 10:10 PM, Shmulik Ladkani wrote:
> On Thu, 05 Feb 2015 15:12:57 -0800 roopa <roopa@cumulusnetworks.com> wrote:
>> We have been playing with ip rules to implement vrfs. And the blocker
>> today is that we cannot bind a socket to a vrf (routing tables in this
>> case).
> Hi Roopa,
>
> One option would be using SO_MARK sockopt on that socket, and have an ip
> rule which matches this mark to point to your table.
> I don't know your exact use-cases, but you can play around with that
> idea.
sorry for getting back late on this,
  yes, SO_MARK and 'ip rule fwmark'  is an option to bind tx from a socket
to a table. But, There are more things that will be needed on the rx side.
and at this point we are not considering netfilter marking of the 
ingress packets so
haven't been following this option

Thanks.
