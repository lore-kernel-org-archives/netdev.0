From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: Fwd: Network Core
Date: Wed, 5 Nov 2008 12:46:30 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F08@NASANEXMB10.na.qualcomm.com>
References: <530d01580811050939q1c1dc52fra6fc2078d86d36e@mail.gmail.com>
 <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
 <4911FDFF.2060302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Snook <csnook@redhat.com>, "Diego ." <eljedi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:22352 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115AbYKEUqe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 15:46:34 -0500
In-Reply-To: <4911FDFF.2060302@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Chris Snook
> Sent: November-05-08 12:12 PM
> To: Diego .
> Cc: netdev@vger.kernel.org
> Subject: Re: Fwd: Network Core
> 
> Diego . wrote:
> There are a few O'Reilly books about the kernel networking stack, and
> anything
> written in the past few years should be recent enough for your
> purposes.  It
> would probably also be helpful to read articles (such as those on
> lwn.net) about
> new network stack features that have been added.  The commentary there
> will give
> you a general idea of the challenges you'll face, but you'll need to
> complement
> that with experience working with the network code.
> 
> -- Chris
Another idea, at least perhaps from a starting point is to determine whether or not it actually needs to be in user space.  With the addition of the tx ring buffer to af_packet, it should be possible to experiment with your network stack in user space.  Once you're comfortable and feel confident with the stack itself, you can port it to kernel space eventually if you want to.
