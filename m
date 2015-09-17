From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 11:45:58 -0700
Message-ID: <CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34167 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbIQSp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:45:58 -0400
Received: by igcpb10 with SMTP id pb10so19423911igc.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:45:58 -0700 (PDT)
In-Reply-To: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> These seem to have been accidentally dropped in commit 371bd1061d29
> ("geneve: Consolidate Geneve functionality in single module.").
>
Geneve should not export vxlan feature. So that it never sees vxlan
tagged packets. Can you turn off the vlan feature?
