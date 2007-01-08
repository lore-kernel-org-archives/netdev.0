From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Mon, 8 Jan 2007 21:30:02 +0100
Message-ID: <200701082130.02948@nessa>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103172301.GA27191@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep13-int.chello.at ([213.46.255.15]:38101 "EHLO
	viefep16-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932648AbXAHUaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 15:30:10 -0500
To: netfilter-devel@lists.netfilter.org
In-Reply-To: <20070103172301.GA27191@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi Evgeniy,

On Wednesday 03 January 2007 18:23, Evgeniy Polyakov wrote:
> Out of curiosity, would you use netchannels [1] if the implementation
> will be much broader? Since what you have created works exactly like
> netchannels netfilter NAT target (although it does not change ports,
> but it can be trivially extended), but without all existing netfilter
> overhead and without hacks in core TCP/UDP/IP/route code.

  Indeed, a netchannels based implementation would be very nice. Combined 
with a userspace network stack I think this could be a very powerful 
tool, especially for people doing dirty tricks -- like transparent 
proxying in our case.

  However, I think that adopting netchannels now would be an enormous work 
on our part. Of course, personally I'm really interested in netchannels 
and the related projects, but I agree with Harald that we still have a 
long way to go before being able to switch to netchannels. And I 
definitely _hate_ the previous incarnations of our tproxy patches enough 
that even this patchset seems acceptable for me. ;)

-- 
 Regards,
  Krisztian Kovacs
