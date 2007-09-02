From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 1/3] netlink: use the macro min(x,y) provided by <linux/kernel.h> instead
Date: Sun, 2 Sep 2007 08:56:54 +0800
Message-ID: <91b13c310709011756n40ca15fao55d88d3754f0c292@mail.gmail.com>
References: <1188675959178-git-send-email-crquan@gmail.com>
	 <46DA07B8.4050204@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cr_quan@163.com
To: "David Newall" <david@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:58300 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932790AbXIBA4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 20:56:55 -0400
Received: by nf-out-0910.google.com with SMTP id f5so960064nfh
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 17:56:54 -0700 (PDT)
In-Reply-To: <46DA07B8.4050204@davidnewall.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/2/07, David Newall <david@davidnewall.com> wrote:
> Denis Cheng wrote
> > +     order = get_bitmask_order(min(max, (unsigned long)UINT_MAX)) - 1;
> >
>
> Why doesn't this clash with the max define, also in linux/kernel.h?
They indeed don't clash,
the cpp included by gcc is intelligent enough, it know the
function-style definition of max in kernel.h, that's different from
the auto variable max here, so they don't clash with each other,

But I think the variable name "max" here is ambiguous, I changed it to
"limit", see my following patch [PATCH 2/3].

-- 
Denis Cheng
