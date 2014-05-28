From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] actions: correctly report the number of actions
 flushed
Date: Wed, 28 May 2014 16:56:07 -0700
Message-ID: <20140528165607.6e3938cd@nehalam.linuxnetplumber.net>
References: <1400937215-15542-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:61632 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbaE1X4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 19:56:10 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so11788365pad.25
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 16:56:10 -0700 (PDT)
In-Reply-To: <1400937215-15542-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 May 2014 09:13:35 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This also fixes a long standing bug of not sanely reporting the
> action chain ordering
> 
> Sample scenario test
> 
> on window 1(event window):
> run "tc monitor" and observe events
> 
> on window 2:
> sudo tc actions add action drop index 10
> sudo tc actions add action ok index 12
> sudo tc actions ls action gact
> sudo tc actions flush action gact
> 
> See the event window reporting two entries
> (doing another listing should show empty generic actions)
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied all 3 action patches, thanks
