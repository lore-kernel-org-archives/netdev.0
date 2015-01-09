From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Add ovs_vport_get_index() to hide
 vport implementation
Date: Thu, 8 Jan 2015 20:10:31 -0800
Message-ID: <CALnjE+rCX-2z=jzJ5pnH6kzGdkM+MYAr=f8uz0etvOYFufxC9A@mail.gmail.com>
References: <1420674525-18253-1-git-send-email-daniele.di.proietto@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:58947 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754079AbbAIEKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 23:10:32 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so6274413igd.2
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 20:10:31 -0800 (PST)
In-Reply-To: <1420674525-18253-1-git-send-email-daniele.di.proietto@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 3:48 PM, Daniele Di Proietto
<daniele.di.proietto@gmail.com> wrote:
> datapath.c should not access private vport data. This commit adds
> 'ovs_vport_get_index()' to vport.c and '.get_index()' to vport_ops
> to hide vport implementation details.
>
Earlier patch was better. There is no need to introduce new
ovs_vport_get_index() since no other vport type can have ifindex.
