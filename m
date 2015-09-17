From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 13:00:12 -0700
Message-ID: <CALnjE+oMSM4+a1Uib0g6PeBbt5Dp0QYCaz678R30Ov-fb_wT3w@mail.gmail.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
	<CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
	<20150917192534.GE25806@tuxdriver.com>
	<CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36850 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbbIQUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:00:13 -0400
Received: by igcrk20 with SMTP id rk20so3392606igc.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 13:00:13 -0700 (PDT)
In-Reply-To: <CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 12:48 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Sep 17, 2015 at 12:25 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
>> On Thu, Sep 17, 2015 at 11:45:58AM -0700, Pravin Shelar wrote:
>>> On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
>>> <linville@tuxdriver.com> wrote:
>>> > These seem to have been accidentally dropped in commit 371bd1061d29
>>> > ("geneve: Consolidate Geneve functionality in single module.").
>>> >
>>> Geneve should not export vxlan feature. So that it never sees vxlan
>>> tagged packets. Can you turn off the vlan feature?
>>
>> I'm not sure I understand...?  This is vlan, not vxlan.
>
> I think he just mean vlan. If you remove the line where
> dev->vlan_features are set then the core stack will handle this and we
> don't need to do anything special here.

Yes, I meant vlan, sorry for confusion.
