From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip tap: Simplify add 'tap' device w/o mode
Date: Mon, 2 Mar 2015 00:03:40 +0200
Message-ID: <20150301220340.GA24166@angus-think.lan>
References: <1425117586-21461-1-git-send-email-vadim4j@gmail.com>
 <20150301140715.0a2c7ef2@urahara>
 <CAPFHKze1coUHyfD_=BKCnXLoLUvbpspcTCHyLGbxmGM0h0QwdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Vadim Kochan <vadim4j@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:45363 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbbCAWPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:15:05 -0500
Received: by wesp10 with SMTP id p10so27781787wes.12
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:15:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAPFHKze1coUHyfD_=BKCnXLoLUvbpspcTCHyLGbxmGM0h0QwdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2015 at 05:13:39PM -0500, Jonathon Reinhart wrote:
> On Sun, Mar 1, 2015 at 5:07 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > No. mode should not depend on device name.
> 
> Isn't this looking at the "tap" part of "ip tap", not the device name?

Right it checks 'ip tap' not the device name.
