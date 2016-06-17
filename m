From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 14:47:51 -0600
Message-ID: <41801a15-fd99-6916-211c-705b4445023d@cumulusnetworks.com>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc>
 <1466178968-27439-2-git-send-email-phil@nwl.cc>
 <ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com>
 <20160617093401.24ae66b1@xeon-e3> <5764295E.7070103@iogearbox.net>
 <9e1c05c7b4894137a80bdb3d2a361bbc@HQ1WP-EXMB11.corp.brocade.com>
 <20160617115753.6205562d@xeon-e3>
 <d122479b-f5cb-2dce-b0ba-d28f3254db32@cumulusnetworks.com>
 <57645F37.5010100@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Hemminger <shemming@brocade.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34913 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcFQUry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 16:47:54 -0400
Received: by mail-pa0-f48.google.com with SMTP id hl6so31496381pac.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 13:47:53 -0700 (PDT)
In-Reply-To: <57645F37.5010100@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/16 2:36 PM, Daniel Borkmann wrote:
>
> Once again, you have to ask Nicolas or Julien for their RHEL version,
> not me ... please have a look at 8f80d450c3cb. ;)

I did, just ran right over the Author ;-)

>
> I just pointed to the fact that this would basically undo their changes
> that they've submitted some time ago to the BPF frontend, reintroducing
> the issue for them. Unfortunately, the anonymous struct cannot be named
> due to uapi reasons. It should have been named from the very beginning,
> but unfortunately too late now. So I would suggest to just leave those
> affected parts as is.

I was referring to Phil's patch. All of the struct {} req; 
initializations should be fine if you name the structs, but then need to 
run it through whatever compiler version the 6wind folks care about to 
verify that is true.
