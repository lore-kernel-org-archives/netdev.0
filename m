From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: incorrect tcp options with window scale
Date: Fri, 22 Aug 2008 20:26:51 -0700
Message-ID: <396556a20808222026r6a262683ha803d515671d201d@mail.gmail.com>
References: <57D3C658-5084-417D-8365-20637A3BB79B@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Philip Love" <love_phil@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:43845 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbYHWD0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 23:26:52 -0400
Received: by rv-out-0506.google.com with SMTP id k40so723516rvb.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 20:26:51 -0700 (PDT)
In-Reply-To: <57D3C658-5084-417D-8365-20637A3BB79B@emc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 7:15 PM, Philip Love <love_phil@emc.com> wrote:
> When window scaling is enabled, but the tcp buffer sizes are small, then the
> tcp SYN packet created will have an incorrect tcp header length. The tcp
> length is calculated assuming that the window scale option will be inserted
> into the tcp header, but since the buffer sizes are too small the window
> scale is not used. Therefore the last 4 bytes of the options in the tcp
> header are left uninitialized.

I suck again.

David, can you hold off on this patch for a day? I think it's correct,
but there might be another similar case with the SYNACKs that I'll
look at once I've slept.

Cheers


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
