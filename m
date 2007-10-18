From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: about multiple network interface
Date: Thu, 18 Oct 2007 17:28:36 +0400
Message-ID: <20071018132836.GA15906@2ka.mipt.ru>
References: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: wit <is01kzh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50422 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764504AbXJRN2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 09:28:35 -0400
Content-Disposition: inline
In-Reply-To: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 09:06:40PM +0800, wit (is01kzh@gmail.com) wrote:
> Hi all,
> 
>    Sorry, I don't know if this is the right mail list. I got the
> following question:
>    I have a e100 card and a e1000 card. Whenever I boot the system, I
> found the eth0 matches the e1000 card, and the eth2 matches the other.
> How can I force the eth0 to match the e100 card and the eth2 to match
> e1000?

Hi.

Check your /etc/modprobe.conf and put there

alias eth0 e100
alias eth2 e1000


-- 
	Evgeniy Polyakov
