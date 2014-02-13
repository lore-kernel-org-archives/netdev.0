From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 17:20:16 -0800
Message-ID: <CAHA+R7NJ2uPbVdcdktD9R-_1QZnbwJXV+NP6jK0_ZTn=TF687g@mail.gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140212083322.1559f441@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:59244 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaBMBUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 20:20:18 -0500
Received: by mail-la0-f43.google.com with SMTP id pv20so7627948lab.2
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:20:16 -0800 (PST)
In-Reply-To: <20140212083322.1559f441@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 8:33 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> This also breaks propogation of state changes from lower device
> to upper device. Things like carrier and up/down.
>

macvlan_device_event() handles this pretty well by using a pointer to
net_device.
I don't see it is a problem from the code.
