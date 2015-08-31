From: Rick Jones <rick.jones2@hp.com>
Subject: Re: vethpair creation performance, 3.14 versus 4.2.0
Date: Mon, 31 Aug 2015 14:31:10 -0700
Message-ID: <55E4C79E.1060101@hp.com>
References: <55E4AF74.7030107@hp.com> <55E4C748.1070300@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:49821 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbbHaVbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 17:31:12 -0400
In-Reply-To: <55E4C748.1070300@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2015 02:29 PM, David Ahern wrote:
> On 8/31/15 1:48 PM, Rick Jones wrote:
>> My attempts to get a call-graph have been met with very limited success.
>>   Even though I've installed the dbg package from "make deb-pkg" the
>> symbol resolution doesn't seem to be working.
>
> Looks like Debian does not enable framepointers by default:
>
> $ grep FRAME /boot/config-3.2.0-4-amd64
> ...
> # CONFIG_FRAME_POINTER is not set
>
> Similar result for jessie.

And indeed, my config file has a Debian lineage.

rick
