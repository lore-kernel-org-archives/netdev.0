From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Configuring the same IP on multiple addresses
Date: Mon, 29 Oct 2007 15:44:26 -0400
Message-ID: <4726381A.6050002@hp.com>
References: <OFF06924F1.9917F90F-ON88257383.006B3289-88257383.006B98D2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:39675 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756081AbXJ2Tox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 15:44:53 -0400
In-Reply-To: <OFF06924F1.9917F90F-ON88257383.006B3289-88257383.006B98D2@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 10/29/2007 11:03:37 AM:
> 
>> So, I am looking for technical reasons why this is permitted.
> 
> Vlad,
>         Is there a technical reason to disallow it? Rather than
> anticipate all the possible uses for a machine, it's, of course,
> generally better to restrict only the things you know can't
> work, and allow everything else.
> 
>                                                         +-DLS

For v4, not really, but it really confuses some people (and thus causes
me headaches ;-)

For v6, there are plenty of operational reasons to not allow this.  You really
turn unicast into anycast when you do this and there are special rules to
be followed.

-vlad
