From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH 6/7] net: ixgbe: add minimal parser details for ixgbe
Date: Tue, 2 Feb 2016 18:27:42 +0200
Message-ID: <CAJ3xEMi_4N-x=_jKaJ8_f2BxHhrhhiCuftwzmqNZaiGv_d1c9w@mail.gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
	<20160201015238.13871.81573.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, ast@fb.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	horms@verge.net.au, Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:32814 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbcBBQ1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:27:42 -0500
Received: by mail-ig0-f175.google.com with SMTP id z14so64548702igp.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:27:42 -0800 (PST)
In-Reply-To: <20160201015238.13871.81573.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2016 at 3:52 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> This adds an ixgbe data structure that is used to determine what
> headers:fields can be matched and in what order they are supported.
>
> For hardware devices this can be a bit tricky because typically
> only pre-programmed (firmware, ucode, rtl) parse graphs will be
> supported and we don't yet have an interface to change these from
> the OS. So its sort of a you get whatever your friendly vendor
> provides affair at the moment.
>
> In the future we can add the get routines and set routines to
> update this data structure. One interesting thing to note here
> is the data structure here identifies ethernet, ip, and tcp
> fields without having to hardcode them as enumerations or use
> other identifiers.

Maybe for the current state this patch (or the most of it) can be
made generic and provided in a way that  multiple HW drivers can use it?
