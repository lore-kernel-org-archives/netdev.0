From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Mon, 16 Mar 2015 15:46:54 +0100
Message-ID: <5506ECDE.6000302@iogearbox.net>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com> <5505EFC4.1070403@iogearbox.net> <20150316132230.GA1100@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52288 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832AbbCPOq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 10:46:57 -0400
In-Reply-To: <20150316132230.GA1100@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2015 02:22 PM, Vadim Kochan wrote:
...
> Also I was thinking about to get rid of this '-nm | -name' option and
> resolve class names by default if they are in /etc/iproute2/cls_names or
> specified by -cf option, what do you think ?

Generally, I think that would be good, but it could break applications
or shell scripts' expectations if they do parse tc output. I think if
admins do care, they could simply set up an alias.

Cheers,
Daniel
