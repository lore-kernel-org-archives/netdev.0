From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 1/2] vxlan: fix hlist corruption
Date: Mon, 3 Jul 2017 10:23:59 +0200
Message-ID: <20170703102359.246d68a2@griffin>
References: <cover.1499014738.git.jbenc@redhat.com>
        <61fd10b88f9eeab8f95a3a73f7e27358fcdcd781.1499014738.git.jbenc@redhat.com>
        <38e4eb5a-2d9e-4f38-f043-42a1dd449bfb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        pravin shelar <pshelar@ovn.org>
To: Waiman Long <longman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751479AbdGCIYK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 04:24:10 -0400
In-Reply-To: <38e4eb5a-2d9e-4f38-f043-42a1dd449bfb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Jul 2017 16:06:10 -0400, Waiman Long wrote:
> I didn't see any init code for hlist4 and hlist6. Is vxlan_dev going to
> be *zalloc'ed so that they are guaranteed to be NULL? If not, you may
> need to add  init code as not both hlists will be hashed and so one of
> them may contain invalid data.

Yes, it's zalloced via alloc_netdev. No need to init the fields
explicitly.

 Jiri
