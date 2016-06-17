From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 18:46:22 +0200
Message-ID: <5764295E.7070103@iogearbox.net>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc>	<1466178968-27439-2-git-send-email-phil@nwl.cc>	<ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com> <20160617093401.24ae66b1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	julien.floret@6wind.com, nicolas.dichtel@6wind.com
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33792 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcFQQqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:46:32 -0400
In-Reply-To: <20160617093401.24ae66b1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2016 06:34 PM, Stephen Hemminger wrote:
> On Fri, 17 Jun 2016 16:09:20 +0000
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> Please have a look at commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") ...
>>
>> Your changes effectively revert them again. Here, and some other parts of the bpf frontend
>> code bits.
>
> GCC 4.6 is 3 years old. So perhaps it is time to move on.
> Maybe add a GCC version check in the makefile, to fail cleanly.

Well, you don't have to ask me but rather the patch submitters (Cc).

I haven't used RHEL in quite a while, but I could imagine it might
be related to built it there perhaps.
