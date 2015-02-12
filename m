From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/7] ebpf: extend program type/subsystem registration
Date: Thu, 12 Feb 2015 22:06:05 +0100
Message-ID: <54DD15BD.7040306@iogearbox.net>
References: <CAMEtUuxwdk8RDbUbo8SO9zMU2ELgf-xZynEeT5i5JBNLc2Y_Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43885 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbBLVGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 16:06:45 -0500
In-Reply-To: <CAMEtUuxwdk8RDbUbo8SO9zMU2ELgf-xZynEeT5i5JBNLc2Y_Hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2015 02:37 AM, Alexei Starovoitov wrote:
...
> My concern that if we allow modules to register new program
> types we allow bypass of gpl and all safety checks we've
> put in place.

Right, I share this concern. That requires to make helper functions
generic enough and shareable among various ebpf users, but that should
be possible, so as mentioned in the other mail, the cls program type
reusing sock_filter_ops is a good way forward.

Thanks for the review!
