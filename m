From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] tc: fill in handle before checking argc
Date: Mon, 11 May 2015 09:13:56 -0700
Message-ID: <20150511091356.252613d5@urahara>
References: <1430865020-16509-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33347 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbEKQNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:13:53 -0400
Received: by pacwv17 with SMTP id wv17so113550070pac.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:13:53 -0700 (PDT)
In-Reply-To: <1430865020-16509-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 May 2015 15:30:20 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> When deleting a specific basic filter with handle,
> tc command always ignores the 'handle' option, so
> tcm_handle is always 0 and kernel deletes all filters
> in the selected group. This is wrong, we should respect
> 'handle' in cmdline.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied
