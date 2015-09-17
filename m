From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 12:48:56 -0700
Message-ID: <CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
 <CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com> <20150917192534.GE25806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:35347 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbIQTtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 15:49:17 -0400
Received: by lagj9 with SMTP id j9so18225807lag.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 12:49:15 -0700 (PDT)
In-Reply-To: <20150917192534.GE25806@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 12:25 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Thu, Sep 17, 2015 at 11:45:58AM -0700, Pravin Shelar wrote:
>> On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > These seem to have been accidentally dropped in commit 371bd1061d29
>> > ("geneve: Consolidate Geneve functionality in single module.").
>> >
>> Geneve should not export vxlan feature. So that it never sees vxlan
>> tagged packets. Can you turn off the vlan feature?
>
> I'm not sure I understand...?  This is vlan, not vxlan.

I think he just mean vlan. If you remove the line where
dev->vlan_features are set then the core stack will handle this and we
don't need to do anything special here.
