From: "Tim Hockin" <thockin@hockin.org>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 1 May 2007 23:51:41 -0700
Message-ID: <b3ece790705012351g5c0ff8a6g9f2f350ff86f3319@mail.gmail.com>
References: <46365887.3010705@interia.pl> <20070501084639.GA528@sirena.org.uk>
	 <46371590.4090004@interia.pl> <20070501180830.GA31630@sirena.org.uk>
	 <46379A7E.3000109@interia.pl> <20070501212750.GC31630@sirena.org.uk>
	 <b3ece790705011543gdca3a9ei905d3499b6c18dc8@mail.gmail.com>
	 <46382798.2090709@interia.pl>
	 <b3ece790705012303x1e5a2d03xddf6c14aec5a99d8@mail.gmail.com>
	 <463830E1.8080107@interia.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "=?UTF-8?Q?Rafa=C5=82_Bilski?=" <rafalbilski@interia.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.230]:18878 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992856AbXEBGvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 02:51:43 -0400
Received: by nz-out-0506.google.com with SMTP id o1so34914nzf
        for <netdev@vger.kernel.org>; Tue, 01 May 2007 23:51:42 -0700 (PDT)
In-Reply-To: <463830E1.8080107@interia.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/1/07, Rafal Bilski <rafalbilski@interia.pl> wrote:

> 2.6.21.1 is first kernel which I'm using at this device. Earlier it was
> WindowsCE terminal. It is hardware fault. Commenting out the code is my
> way to avoid "wakeup" messages in log, but I don't want to change anything
> in vanilla kernel. I'm lucky that NIC is working at all.

I'm not sure what the right answer is.  The code was designed to do
the right thing, and yet in your case it's broken.  Does it need to be
a build option to work around broken hardware?  Yuck.
