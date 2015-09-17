From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 15:25:35 -0400
Message-ID: <20150917192534.GE25806@tuxdriver.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
 <CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57671 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbbIQTaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 15:30:13 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 11:45:58AM -0700, Pravin Shelar wrote:
> On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > These seem to have been accidentally dropped in commit 371bd1061d29
> > ("geneve: Consolidate Geneve functionality in single module.").
> >
> Geneve should not export vxlan feature. So that it never sees vxlan
> tagged packets. Can you turn off the vlan feature?

I'm not sure I understand...?  This is vlan, not vxlan.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
