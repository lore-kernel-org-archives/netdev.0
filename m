From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: use -EEXIST as return error to be more precise
Date: Thu, 30 May 2013 03:02:18 +0900
Message-ID: <CAEP_g=8EqC_9K-0U3uk=4qzXg_QmgPCTocYaA28PQY+aofGnnQ@mail.gmail.com>
References: <1369722676-7898-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:49203 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S964935Ab3E2SCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 14:02:51 -0400
Received: by mail-ie0-f174.google.com with SMTP id aq17so2532854iec.33
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 11:02:38 -0700 (PDT)
In-Reply-To: <1369722676-7898-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 3:31 PM, Fan Du <fan.du@windriver.com> wrote:
> ovs_vport_cmd_new create a new vport with port num specified by user.
> when this port num is already occupied, it's more clear to return
> -EEXIST as the reason than -EBUSY.
>
> Signed-off-by: Fan Du <fan.du@windriver.com>

This error code is part of the userspace ABI so you can't change it
without breaking existing applications.
